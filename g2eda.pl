#----13096_13097.sh
#! /usr/bin/perl
use strict;
use Net::FTP;
use POSIX;
use Net::Cmd;
use File::Basename;
use File::Copy;
use Data::Dumper;

#设置远程路径
my %path=('remote'=>'/'
,'localdir'=>'/pardata/EDADATA/INTERFACE/OTHER/DATA/'
,'back'=>'/pardata/EDADATA/INTERFACE/OTHER/BACKUP/'
,'record'=>'/pardata/EDASCRIPT/publisher0/g2eda/'
,'log'=>'/pardata/EDASCRIPT/publisher0/g2eda/log/');

my @remote_files=('PNEUMONIA','broadband_speed','cloud_busi_manager_collect_day');

#创建ftp对象
my $ftp;

##################################################################
sub getFtp     #::::::FTP通用方法，创建一个通用FTP对象用于远程操作
##################################################################
{
	
	my %connStr=('host'=>'10.254.173.122','user'=>'ftp862','passwd'=>'ftp862#$!%@');
	my $ftp=Net::FTP->new ($connStr{'host'},Passive=>0,Timeout=>30) or die("Can not connnect to ftp server ".$connStr{'host'}.$!);
	$ftp->login($connStr{'user'},$connStr{'passwd'}) or die "Can not login"; #$ftp->message;
	return $ftp;
}
##################################################################
sub matching #从下载列表匹配需要的文件名称
##################################################################
{
	my ($file)=@_;
	my $flag=0;
	foreach my $f(@remote_files){
		 if($file=~/^$f/){
		 	 $flag=1;
		 	 last;
		 }
	}
	return $flag;
}

#################################################################
sub download_hour #下载文件
#################################################################
{
=pod
  1.循环day目录查询有无当天目录
  2.进入当天目录读取所有文件，并且筛选14个分公司
  3.如果14个分公司齐全，开始下载数据
=cut
     my $current_date=strftime("%Y%m%d",localtime(time()-(3600*24)*0));
	 my $ftp=getFtp();#ftp对象
	 my $remote=$path{'remote'};#远程路径
	 my @downlist=();#下载文件列表
	 
	 $ftp->cwd($remote) or die ("Can not into remote dir".$!."\n");#进入远程路径
	 my @list=$ftp->ls($remote);#获取远程路径下所有目录
	 foreach my $f (@list){#循环当前目录中所有文件
			my $fn=getFileName($f);
			if(matching($fn)==1){
				push(@downlist,$fn);#添加到下载列表
			}
     }	
		 
		 my $size=@downlist;#下载列表大小
		 if ($size>=1){#控制文件数量
		    foreach my $f (@downlist){
		    	if(isExeRecord($f)==0){
							msg( "scan file ".$f);
							my $remotefile=$remote."/".$f;
							my $localfile=$path{'localdir'};
							$ftp->get($remotefile,$localfile.$f) or die "Could not get remotefile:$remotefile.\n";
							write_record($f);
		    	}else{
		    	  	msg( $f." is existing");
		    	}
			}
		 }
	 $ftp->quit;	
}

##################################################################
sub getFileName # 通过全路径获取文件名
##################################################################
{
	my ($path0)=@_;
	my $dirname=dirname($path0);
	my $filename=substr($path0,length($dirname));
	return $filename;
}

#################################################################
sub write_record #写入日志
#################################################################                  
{
	 my($str)=@_;
	 my $logfile=$path{'record'}."record.txt";
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
	 my $logfile=$path{'record'}."record.txt";
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

sub SHARE_DATFA{
	  msg("***********************************************************");
	  msg("SHARE DATA START...");
	  msg("***********************************************************");
	  chdir($path{'localdir'});
	  `cp broadband_speed* /pardata/EDADATA/SHARE/TYDK`
}

sub BACKUP_DATA{
	  msg("***********************************************************");
	  msg("BACKUP DATA START...");
	  msg("***********************************************************");	
	  chdir($path{'localdir'});
    my $result=`mv broadband_speed*  $path{'back'}`;
	  print $result;
}

sub main(){
	while(1==1){
	  msg("***********************************************************");
      msg("She prompt PID==>	$$  duanhw ");
      msg("***********************************************************");
		  download_hour();
		  SHARE_DATFA();
		  BACKUP_DATA();
		  msg("1 hour later continue");
		  sleep(5);
	}
}

main();
