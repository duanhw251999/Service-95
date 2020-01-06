#!/usr/bin/perl
use strict;
use FileHandle;
use Net::FTP;
use Cwd;
use Date::Calc qw(Date_to_Time Time_to_Date Add_Delta_Days);
use File::Copy;
use Encode;
use DBI;
use Data::Dumper qw(Dumper);
use POSIX;
use File::Basename;

my %path=(
'source'=>'E:/PERSONAL/Duanhw/xhzw/source/',
'backup'=>'E:/PERSONAL/Duanhw/xhzw/backup/'
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
sub getFtp     #::::::FTPͨ�÷���������һ��ͨ��FTP��������Զ�̲���
##################################################################
{
	msg("create ftp connection");
	my $ftp=defined;
	$ftp=Net::FTP-> new($conStr{'host'},Passive=>0,Timeout=>30) or die("Can not connnect to ftp server ".$conStr{'host'}.$!);
  $ftp->login($conStr{'user'},$conStr{'password'}) or die "Can not login"; #$ftp->message;
	return $ftp;
}

#################################################################
sub download #�����ļ�
#################################################################
{
=pod
  1.ѭ��dayĿ¼��ѯ���޵���Ŀ¼
  2.���뵱��Ŀ¼��ȡ�����ļ�������ɸѡ14���ֹ�˾
  3.���14���ֹ�˾��ȫ����ʼ��������
=cut
	 my $ftp=getFtp();#ftp����
	 my $remote=$conStr{'remotedir'};#Զ��·��
	 my @downlist=();#�����ļ��б�
	 #��ȡ��ǰ����
   #my $current_date=strftime("%Y%m%d",localtime(time()-(3600*24)*1));
	 $ftp->cwd($remote) or die ("Can not into remote dir".$!."\n");#����Զ��·��
	 my @list2=$ftp->ls($remote);#���뵱ǰ����Ŀ¼
   foreach my $f (@list2){#ѭ����ǰĿ¼�������ļ�
   	 my $fn=getFileName($f);
     msg("scan file ".$fn);
     push(@downlist,$fn);#��ӵ������б�
   }

		 my $size=@downlist;#�����б��С
		 if ($size>=1){#�����ļ�����
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
sub write_record #д����־
#################################################################                  
{
	 my($str)=@_;
	 my $logfile=$path{'record'}."record_hour.txt";
   open RE,">>$logfile";
   print RE $str."\n";
   close RE;	
}

#################################################################
sub isExeRecord #�Ƿ������־��
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
sub query #��ѯ
############################################################################################
{
=pod	
	my $sth = $dbh->prepare("SELECT * FROM OTHPDATA.TB_13094_S_RD");   # Ԥ���� SQL  ���
	$sth->execute();    # ִ�� SQL ����
	 
	# ע���ⲿ��ʹ�õ��ǰ�ֵ����
	# $alexa = 20;
	# my $sth = $dbh->prepare("SELECT name, url
	#                        FROM Websites
	#                        WHERE alexa > ?");
	# $sth->execute( $alexa ) or die $DBI::errstr;
	 
	# ѭ�������������
	while ( my @row = $sth->fetchrow_array() )
	{
	       print join('\t', @row)."\n";
	}
	 
	$sth->finish();
=cut	
}
############################################################################################
sub update #����
############################################################################################
{
	my ($dbh,$sql,@record)=@_;
	my $sth = $dbh->prepare($sql);   # Ԥ���� SQL  ���
	$sth->execute(@record);
	$sth->finish();
	$dbh->commit or die $DBI::errstr;
}

############################################################################################
sub read_dat_file #��ȡ�����ļ����Ҳ����
############################################################################################
{
	 my ($dbh,$file)=@_;
	 my $fileName=getFileName($file);
	 my $load_date=substr($fileName,3,8);
	 my $sql="insert into othpdata.TB_13094_S_RD"
   	 ."( id,acc_nbr,port_out_network,port_in_network,owner_network,beging_time,load_date)"
   	 ."values"
   	 ."(?,?,?,?,?,?,?)";
	 msg("load_date==${load_date}");
   open FILEOUT,"<$file";
   my $count=0;
   while(<FILEOUT>){
   	 $count++;
   	 my @temp=split /,/ ,$_;
   	 push (@temp,$load_date);
   	 update($dbh,$sql,@temp);
   }
   close FILEOUT;	
  msg("����${count}�м�¼!");
}

sub trim 
{ 
        my $string = shift; 
        $string =~ s/^\s+//; 
        $string =~ s/\s+$//; 
        return $string; 
} 

##################################################################
sub getFileName # ͨ��ȫ·����ȡ�ļ���
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

sub mv2backup
{
	 `mv $path{'source'}*.*  $path{'backup'}`;
}

sub main()
{
=pod
   1. �����ļ�
   2. ����ļ�
   3. �����ļ�
=cut
	msg("******************************************************");
	msg(" PID==>	$$ 13094 duanhw ");
	msg("******************************************************");
  download();
  loadData();
  mv2backup();
}

main();