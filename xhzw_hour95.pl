#!/usr/bin/perl
use strict;
use FileHandle;
use Net::FTP;
use Cwd;
use Date::Calc qw(Date_to_Time Time_to_Date Add_Delta_Days Mktime);
use File::Copy;
use Encode;
use DBI;
use Data::Dumper qw(Dumper);
use POSIX qw(strftime);
use File::Basename;

my %path=(
'source'=>'E:/PERSONAL/Duanhw/xhzw/source/',
'backup'=>'E:/PERSONAL/Duanhw/xhzw/backup/',
'record'=>'E:/PERSONAL/Duanhw/xhzw/'
);

my %conStr=(
    "host"=>'135.149.64.97',
    "user"=>'GETDATA_EDA',
    "password"=>'Get(3369)edA',
    "remotedir"=>'/XHZW/source/',
    "remotebak"=>"/XHZW/backup/",
    "localdir"=>"E:/PERSONAL/Duanhw/xhzw/source/",
    "localbak"=>"E:/PERSONAL/Duanhw/xhzw/backup/"
);

############################################################################################
sub connectdb
############################################################################################
{
	  my $dbh=defined;
    my($dsn,$user,$passwd)=qw/dbi:Oracle:GSEDA ODSKF !Gs$K2019f#/;
    $dbh = DBI->connect($dsn, $user, $passwd ) or die $DBI::errstr;
    return $dbh;
}


##################################################################
sub getFtp     #::::::FTP通用方法，创建一个通用FTP对象用于远程操作
##################################################################
{
	msg("create ftp connection");
	my $ftp=defined;
	$ftp=Net::FTP-> new($conStr{'host'},Passive=>0,Timeout=>30) or die("Can not connnect to ftp server ".$conStr{'host'}.$!);
  $ftp->login($conStr{'user'},$conStr{'password'}) or die "Can not login"; #$ftp->message;
	return $ftp;
}

#################################################################
sub download #下载文件
#################################################################
{
=pod
  1.循环day目录查询有无当天目录
  2.进入当天目录读取所有文件，并且筛选14个分公司
  3.如果14个分公司齐全，开始下载数据
=cut
	 my $ftp=getFtp();#ftp对象
	 my $remote=$conStr{'remotedir'};#远程路径
	 my @downlist=();#下载文件列表
	 #获取当前日期
   my $current_date=strftime("%Y%m%d",localtime(time()-(3600*24)*1));
	 $ftp->cwd($remote) or die ("Can not into remote dir".$!."\n");#进入远程路径
	 my @list2=$ftp->ls($remote);#进入当前日期目录
   foreach my $f (@list2){#循环当前目录中所有文件
   	 my $fn=getFileName($f);
     msg("scan file ".$fn);
     push(@downlist,$fn);#添加到下载列表
   }

		 my $size=@downlist;#下载列表大小
		 if ($size>=1){#控制文件数量
		    foreach my $f (@downlist){
		    	if(isExeRecord($f)==0){
		    			msg("down file ".$f);
							my $remotefile=$remote.$f;
							my $localfile=$conStr{'localdir'};
							$ftp->get($remotefile,$localfile.$f) or die "Could not get remotefile:$remotefile.\n";
							write_record($f);
		    	}
			  } 
		 }
	 $ftp->quit;	
}

#################################################################
sub write_record #写入日志
#################################################################                  
{
	 my($str)=@_;
	 my $logfile=$path{'record'}."record_hour.txt";
   open RE,">>$logfile";
   print RE $str."\n";
   close RE;	
}

#################################################################
sub isExeRecord #是否存在日志中
#################################################################
{
	 my $isvalue=0;
   my($str)=@_;
	 my $logfile=$path{'record'}."record_hour.txt";
   open RE,"<$logfile";
   while (<RE>) {
   	  if($_=~/$str/){
   	  	 $isvalue=1;
   	     last;
   	  }
   }
   close RE;
   return $isvalue;
}

############################################################################################
sub query #查询
############################################################################################
{
=pod	
	my $sth = $dbh->prepare("SELECT * FROM OTHPDATA.TB_13094_S_RD");   # 预处理 SQL  语句
	$sth->execute();    # 执行 SQL 操作
	 
	# 注释这部分使用的是绑定值操作
	# $alexa = 20;
	# my $sth = $dbh->prepare("SELECT name, url
	#                        FROM Websites
	#                        WHERE alexa > ?");
	# $sth->execute( $alexa ) or die $DBI::errstr;
	 
	# 循环输出所有数据
	while ( my @row = $sth->fetchrow_array() )
	{
	       print join('\t', @row)."\n";
	}
	 
	$sth->finish();
=cut	
}
############################################################################################
sub update #更新
############################################################################################
{
	my ($dbh,$sql,@record)=@_;
	my $sth = $dbh->prepare($sql);   # 预处理 SQL  语句
	$sth->execute(@record);
	$sth->finish();
	$dbh->commit or die $DBI::errstr;
}

############################################################################################
sub read_dat_file #读取数据文件并且插入表  #t_jtd_port_changenet tb_13094_s_rd
############################################################################################
{
	 my ($dbh,$file)=@_;
	 my $fileName=getFileName($file);
	 my $load_date=substr($fileName,3,8);
	 my $sql="insert into othpdata.t_jtd_port_changenet_hour "
   	 ."( id,acc_nbr,port_out_network,port_in_network,owner_network,beging_time,load_date)"
   	 ."values"
   	 ."(?,?,?,?,?,?,?)";
	 msg("load_date==${load_date}");
   open FILEOUT,"<$file";
   my $count=0;
   while(<FILEOUT>){
   	 $count++;
   	 my @temp=split /,/ ,$_;
   	 push (@temp,${load_date});#将load_date加入到每一条记录中去 ${load_date}
   	 
   	 update($dbh,$sql,@temp);
   }
   close FILEOUT;	
  msg("更新${count}行记录!");
}

############################################################################################
sub convert_date # Convert To String
############################################################################################
{
  my ($dt)=@_;
  my ($year,$mon,$day,$hour,$min,$sec);
  my $str;
  if(length($dt)==8){
		$year=substr($dt,0,4);
		$mon=substr($dt,4,2);
		$day=substr($dt,6,2);
		my $time = Mktime($year,$mon,$day,'00','00','00');
		$str= localtime($time);
  }else{
		$year=substr($dt,0,4);
		$mon=substr($dt,5,2);
		$day=substr($dt,8,2);
		$hour=substr($dt,11,2);
		$min=substr($dt,14,2);
		$sec=substr($dt,17,2);
		my $time = Mktime($year,$mon,$day,$hour,$min,$sec);
		$str= localtime($time);
  }
  return strftime "%Y-%m-%d %H:%M:%S", localtime($str);
}

sub trim 
{ 
        my $string = shift; 
        $string =~ s/^\s+//; 
        $string =~ s/\s+$//; 
        return $string; 
} 

##################################################################
sub getFileName # 通过全路径获取文件名
##################################################################
{
	my ($path0)=@_;
	my $dirname=dirname($path0);
	my $filename=substr($path0,length($dirname)+1);
	return $filename;
}

##################################################################
sub msg
##################################################################
{
	my ($message)=@_;
	my $timpstamp=strftime("%Y-%m-%d %H:%M:%S",localtime());
	$timpstamp=strftime("%Y-%m-%d %H:%M:%S",localtime());
	print "\n[${timpstamp}] $message\n";
}

##################################################################
sub readDir
##################################################################
{
	my ($dir)=@_;
  my @files = glob($dir."*");
  return @files;
}

sub loadData
{
	my $dbh=connectdb();#TB_13094_S_RD
	my @files=readDir($path{'source'});
  if(@files){
  	foreach(@files){
			read_dat_file($dbh,$_);
  	}
  }
  $dbh->disconnect();		
}

#################################################################
sub is_emptydir #判断目录是否为空
#################################################################
{
    my $isvalue=1;
    my ($dirname)=@_;
    my @dir_files = <$dirname/*>;
	if (@dir_files) {                                                                            
        msg( Dumper @dir_files);     
	} else {                                                                                                                                                                    
        msg("empty");
        $isvalue=0;		
    }	
    return $isvalue;	
}

sub mv2backup
{
	if(is_emptydir($path{'source'})!=0){
			 `mv $path{'source'}*.*  $path{'backup'}`;
	}
}

sub main()
{
=pod
   1. 下载文件
   2. 入库文件
   3. 备份文件
   while(1==1){
		msg("******************************************************");
		msg(" PID==>	$$ 13094 duanhw ");
		msg("******************************************************");
	  download();
	  loadData();
	  mv2backup();
	  msg("1 hour later continue");
	  sleep(60*60);
  }
   
=cut
		msg("******************************************************");
		msg(" PID==>	$$ 13094 duanhw ");
		msg("******************************************************");
	  download();
	  loadData();
	  mv2backup();
	  msg("1 hour later continue");
}

main();
