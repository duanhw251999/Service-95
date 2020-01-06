#! /usr/bin/perl

use strict;
use Net::FTP;
use POSIX;
use Net::Cmd;
use File::Basename;
use File::Copy;
use Data::Dumper;



#设置远程路径
my %path=('remote'=>'/app/plsmsftp/day/biz/'
,'localdir'=>'/pardata/EDASCRIPT/publisher0/xhzw/day/source/'
,'unpack'=>'/pardata/EDASCRIPT/publisher0/xhzw/day/unpack/'
,'record'=>'/pardata/EDASCRIPT/publisher0/xhzw/rec/');
#创建ftp对象
my $ftp;

##################################################################
sub getFtp     #::::::FTP通用方法，创建一个通用FTP对象用于远程操作
##################################################################
{
	msg("create ftp connection");
	my $ftp=defined;
	my %connStr=('host'=>'135.149.34.102','user'=>'plsmsftp_crm','passwd'=>'NP_crmgs#@!102','port'=>'10018');
	$ftp=Net::FTP->new ($connStr{'host'},Port=>$connStr{'port'},Passive=>0,Timeout=>30) or die("Can not connnect to ftp server ".$connStr{'host'}.$!);
  $ftp->login($connStr{'user'},$connStr{'passwd'}) or die "Can not login"; #$ftp->message;
	return $ftp;
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
sub validName # 验证名称是否否和要求
##################################################################
{
	my $flag=0;
	my ($name)=@_;
	my @rule=qw/930 931 932 933 934 935 936 937 938 939 941 943 945 947/;
	my $latn_code=substr $name,4,3;
	if(grep { $_ eq $latn_code } @rule){
		$flag=1;
    }
  return $flag;
}

#################################################################
sub emptydir # 清空目录
#################################################################
{
	my ($dirname)=@_;
	 opendir ( DIR, $dirname ) || die "Error in opening dir $dirname\n";
   my @files = readdir (DIR);
   foreach my $f(@files){
   	  if($f=~/^[^\.]/){
   	   unlink $dirname.$f;
   	  }
   }
   closedir DIR;
}

#################################################################
sub unzip #解压
#################################################################
{
	 my ($dirname)=@_;
	 opendir ( DIR, $dirname ) || die "Error in opening dir $dirname\n";
   my @files = readdir (DIR);
   foreach my $f(@files){
   	  if($f=~/^[^\.]/){
   	   msg($f." Will be unzipped");	#替换解压命令
       `tar -xvf $dirname$f -C $path{'unpack'}`;
   	  }
   }
   closedir DIR;
}

#################################################################
sub clean_empty_file #清理记录为0的文件
#################################################################
{
	 my ($dirname)=@_;
	 opendir ( DIR, $dirname ) || die "Error in opening dir $dirname\n";
	 my @files = readdir (DIR);
   foreach my $f(@files){
   	   my $line= readTxtLine($dirname.$f);
   	   if($line==1){
      	msg( $f."is empty file will clean");
      	unlink $dirname.$f;
      }  
   }
	 closedir DIR;
}
#################################################################
sub readTxtLine #读取文件行数
#################################################################
{
   my($file)=@_;
   open FILEOUT,"<$file";
   my $count=0;
   while(<FILEOUT>){
   	 $count++;
   }
   close FILEOUT;
	 #print $file." $count\n";
	 return $count;
}
#################################################################
sub cut_dat #删除第一行
#################################################################
{
   my ($dirname)=@_;
   chdir($dirname);
   opendir ( DIR, $dirname ) || die "Error in opening dir $dirname\n";
   my @files=readdir(DIR);
   foreach(@files){
      if($_!~/[.]/){
      	   cut_tworow($dirname,$_);				
	    }
   }
   closedir DIR;
}
#################################################################
sub cut_tworow #删除第一行辅助
#################################################################
{
  my ($path,$oldname)=@_;
  my $count=0;
  my $newname="temp.txt";
  msg( $path.$oldname.">>>>>".$path.$newname);
  
  open FILE,"<$path$oldname";
  open NEWFILE ,">$path$newname";
  while(<FILE>){
     if($count>0){
				print NEWFILE $_;
	 	 }
     $count++;
  }
  close FILE;
  close NEWFILE;
  
  unlink $path.$oldname;
  move $path.$newname,$path.$oldname.".dat"; #i_20191104_12055_00_001.dat
  
}

sub modifydat #修改dat文件名称
{
	my ($dirname)=@_;
	my $current_date=strftime("%Y%m%d",localtime(time()-(3600*24)*1));
	chdir($dirname);
	opendir ( DIR, $dirname ) || die "Error in opening dir $dirname\n";
	my @files=readdir(DIR);
	
  my $size=@files;
  
  my $count=0;
  foreach my $f(@files){
  	$count++;
  	if($f=~/^[^\.]/){
  		 move  $dirname.$f ,$dirname."s_${current_date}_13093_00_".(length($count)==2?"0".$count:"00".$count).".dat";
    }
  }
	closedir DIR;
}

#################################################################
sub buildVerf # 创建校验文件
#################################################################
{ #i_20191114_12055_00.verf
	 my ($dirname)=@_;
	 #获取当前日期
   my $current_date=strftime("%Y%m%d",localtime(time()-(3600*24)*1));
   chdir($dirname);
   opendir ( DIR, $dirname ) || die "Error in opening dir $dirname\n";
   open VERF,">$dirname"."s_${current_date}_13093_00.verf";
   my @files=readdir(DIR);
   foreach(@files){
      if($_=~/^[^\.]/){
      	   if($_=~/.dat/){
      	   	 my @args = stat ($dirname.$_);
      	   	 my $timpstamp=strftime("%Y%m%d%H%M%S",localtime());
      	   	 
      	   	 my $name=sprintf("%-40s",$_);
      	   	 my $size0=sprintf("%-20s",$args[7]);
      	   	 my $line0=sprintf("%-20s",readTxtLine($dirname.$_));
      	   	 my $time0=sprintf("%-20s",$current_date." ${timpstamp}");
      	   	 
      	   	 print 	VERF $name.$size0.$line0." ".$time0."\n";
      	   }
	    }
   }
   close VERF;
   closedir DIR;
}

sub move2bss
{
  `mv /pardata/EDASCRIPT/publisher0/xhzw/day/unpack/*.* /pardata/EDADATA/INTERFACE/BSS/DATA/`;	
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
	 my $remote=$path{'remote'};#远程路径
	 my @downlist=();#下载文件列表
	 #获取当前日期
   my $current_date=strftime("%Y%m%d",localtime(time()-(3600*24)*1));
	 $ftp->cwd($remote) or die ("Can not into remote dir".$!."\n");#进入远程路径
	 my @list=$ftp->ls($remote);#获取远程路径下所有目录
		 foreach my $d (@list){
		 	    msg("scan dir ".$d);
		 	  	if (getFileName($d)==$current_date){#如果目录中有当前日期目录
		 	  	   my @list2=$ftp->ls($d);#进入当前日期目录
		 	  	   foreach my $f (@list2){#循环当前目录中所有文件
		 	  	   	 my $fn=getFileName($f);
		 	  	     if($fn=~/gz/){#如果是gz文件
		 	  	     	  if(validName($fn)==1){#如果是930-947文件
		 	  	     	  	  msg("scan file ".$fn);
		 	  	     	    	push(@downlist,$fn);#添加到下载列表
		 	  	     	  }
		 	  	     }
		 	  	   }
		 	  	}		 	  	
		 } 	
		 

		 my $size=@downlist;#下载列表大小
		 if ($size>=12){#控制文件数量
		    foreach my $f (@downlist){
		    	if(isExeRecord($f)==0){
							msg("down file ".$f);
							my $remotefile=$remote.$current_date."/".$f;
							my $localfile=$path{'localdir'};
							$ftp->get($remotefile,$localfile.$f) or die "Could not get remotefile:$remotefile.\n";
							write_record($f);
		    	}
			}
		 }
		  	
	 $ftp->quit;	
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

sub msg{
	my ($message)=@_;
	my $timpstamp=strftime("%Y-%m-%d %H:%M:%S",localtime());
	$timpstamp=strftime("%Y-%m-%d %H:%M:%S",localtime());
	print "\n[${timpstamp}] $message...\n";
}

sub main(){
=pod
  1.清空下在目录
  2.清空解压目录
  3.下载文件
  4.解压文件
  5.删除记录为0的文件
  6.删除第一行
  7.修改数据文件名称
  8.创建verf文件
  9.移动文件到bss/data
  NP_crmgs#@!102 Lqzm1-rcn7m 15tkh_16Sss
=cut
   while(1==1){
      my $timpstamp=strftime("%Y-%m-%d %H:%M:%S",localtime());
      msg("***********************************************************");
      msg("She prompt PID==>	$$ 13093 duanhw ");
      msg("***********************************************************");
			emptydir($path{'localdir'});
			emptydir($path{'unpack'});
			download();
			  if(is_emptydir($path{'localdir'})!=0){
					unzip($path{'localdir'});
					clean_empty_file($path{'unpack'});
					cut_dat($path{'unpack'});
					modifydat($path{'unpack'});
					buildVerf($path{'unpack'});
					move2bss();
			}
			msg("1 hour later continue");
			sleep(60*60);
	 }
}

main();
