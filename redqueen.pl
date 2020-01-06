#!/usr/bin/perl
#use strict;
use Net::FTP;

############################################
my @hr=qw/10.254.173.122 ds_ftp_862 Nm&ZyC_19 21/;# 人力资源
my @nm=qw/10.254.173.122 ftp862 ftp862#$!%@ 21/; #内蒙 saorao
my @smartbroad=qw/10.128.21.67 GSBUS3602820190404 K5Xj4SoXo11 2121/;#智慧宽带  sbroad
my $downloadDir="/pardata/EDASCRIPT/publisher0/jtother/";
my $logDir="/pardata/EDASCRIPT/publisher0/log/redqueen.log";
my $shareDir="/pardata/EDADATA/SHARE/";
my $backup="/pardata/EDADATA/JT_SOURCE/DAY/";

my %saorao=('name'=>'credit_saorao_result','bos'=>'NULL','SHARE'=>'BONC');
my %sbroad=('name'=>'BUS360','bos'=>'NULL','SHARE'=>'NULL');
my %label=('name'=>'LDAPM_IOT_PO_MEMBER','bos'=>'NULL','SHARE'=>'EDW');

=pod
DAPM_GU_BDM_LABEL_PORTRAIT
DAPM_GU_BDM_LABEL_BASICS
DAPM_GU_BDM_LABEL_MASTER
DAPM_GU_BDM_LABEL_GE
=cut


############################################
sub main # boot function
############################################
{ 
	# 1. 下载文件
	# 2. 对SHare字段不是NULL的进行共享
	# 3. 对需要解压的文件进行解压
	# 4. 对解压后的文件，进行转接口
	download($label{'name'},@nm);
	#download($sbroad{'name'},@smartbroad);
	#gunzipFiles($downloadDir);
	#getChildDir($downloadDir);
}



############################################
sub connect_remote # connect ftp function
############################################
{
	my ($host,$user,$passwd,$port)=@_;
	my $ftp=Net::FTP->new($host,Port=>$port,Passive=>1,Timeout=>30) or die "Can not connect to ftp $@";
	$ftp->login($user,$passwd) or die "Can not login" ;
  return $ftp;
}
############################################
sub download
############################################
{
	my ($findStr,@connStr)=@_;
	my $ftp=connect_remote(@connStr);
	my @items=$ftp->ls();
	foreach my $i (@items){
	  if(!(-d $i)){
	  	if($i=~/$findStr/){
	  		print $i."\n";
=pod	  		
	  		#my @full=split(/\//,$i);
	  		#my $name=$full[1];
=cut	  		
	  		my $name=$i;
	  		if(readlog($name)==0){
	  			$ftp->get($i,$downloadDir.$name);
	  			print 	$name."   is downloaded......\n";
	  			writelog($name);
	  	  }else{
	  	  	print 	$name."   already exists,don't need to download......\n";
	  	  }	  	  
	  	}
	  }
	}
	$ftp->quit;
	#getLocalFiles($downloadDir,$saorao{'name'});
}


############################################
sub getLocalFiles
############################################
{
	my ($path0,$pattern)=@_;
	opendir(DIRFILE,$path0);
	my $cur=Get_before_time(3);
	my @Files =sort(grep(/$pattern/,readdir(DIRFILE)));
	foreach (@Files){
		if($_=~/$cur/){
			system("cp $path0".$_." $shareDir".$saorao{'SHARE'}.'/'.$_);
			print $path0.$_." >>> ".$shareDir.$saorao{'SHARE'}.'/'.$_."\n";
			system("mv $path0".$_." $backup");
		}

	}
	close DIRFILE;
}
############################################
sub gunzipFiles #解压
############################################
{
	my ($path0)=@_;
	opendir(DIRFILE,$path0);
	my $cur=Get_before_time(1);
	my @Files =sort(grep(/.tar.gz/,readdir(DIRFILE)));
	foreach (@Files){
		if($_=~/$cur/){
			system("tar -xvf ${path0}".$_." -C ${path0}");
			print $path0.$_." GUNZING ......\n";
		}

	}
	close DIRFILE;
}
############################################
sub getChildDir #获取子目录
############################################
{
	my ($path0)=@_;
	opendir(DIRFILE,$path0);
	my @Files =sort(readdir(DIRFILE));
	foreach (@Files)
	{ 
		if(-d ("${path0}".$_)){
			if($_=~/^[^\.]/){
				intoDir("${path0}".$_);
			}
		}
	}
	close DIRFILE;
}

sub intoDir
{
	my ($path0)=@_;
	opendir(DIRFILE,$path0);
	my @Files =sort(readdir(DIRFILE));
	foreach (@Files){
		if($_=~/^[^\.]/){
	  print $_."\n";	
	  }
	}
	close DIRFILE;
}

############################################
sub writelog  #写入日志
############################################
{
	 my ($filename)=@_;
   open ILOG,">> $logDir";
   print ILOG $filename."\n"; 
   close ILOG;
}

############################################
sub readlog #读取日志
############################################
{
	  my $flag=0;
	  my ($filename)=@_;
  	open ILOG,"< $logDir";
  	while(<ILOG>){
  	   if($_=~/$filename/){
  	      $flag=1;
  	      last;
  	   }
  	}
  	close ILOG;
  	return $flag;
}

#==================================================================================================
sub Get_before_time  #该函数实现::根据传递进来的参数,用当前时间减去相应天数，得到对应日期    
#====================================================================================================
{
  my ($cha)=@_;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time()-$cha*24*60*60);
	$year += 1900;
	$mon+=1;
	if ($mon < 10)  { $mon="0".$mon;  } else { $mon=$mon;}
	if ($mday < 10) { $mday="0".$mday; } else { $mday=$mday; }
	my $SysDate=sprintf("%4d%02d%02d",$year,$mon,$mday);
	
	return $SysDate;
}


&main();
