#!/usr/bin/perl
use strict;
use File::Copy;
use Cwd;

=pod
      	1.进入realdata目录
        2.读取dat文件和verf文件，并将文件放入日期+接口的文件夹内
        3.
=cut
my %paths=(
 'REALDATA'=>'/pardata/EDADATA/INTERFACE/BSS/REALDATA/',
 'BSS_BACKUP'=>'/pardata/EDADATA/INTERFACE/BSS/BACKUP/',
 'BAKCUP'=>'/pardata/EDADATA/INTERFACE/BSS/REALDATA/BAKCUP/'
);

# 读取处理目录
sub listdir{
	opendir (REALDATA ,$paths{'REALDATA'}) or die "open dir faild,$!";
	while (my $f =readdir REALDATA){
	if(!($f=~/^[.]+/)){
		if(!(-d $paths{'REALDATA'}.$f)){
			 buildDir($f);
		}
	}
	}
	closedir REALDATA;
	msg("STEP2::::::::::::::::listdir function finish......\n");
}


# 根据文件名称创建目录 s_20190819_30001_00_8030662.dat
sub buildDir{
	  my ($name)=@_;
	  my @arr=split(/\_/,$name);
	  if(length($arr[2])==5){
	  	my $sub_dir=$arr[1].$arr[2];
	  	if(-e $paths{'REALDATA'}.$sub_dir){
	  		 move($paths{'REALDATA'}.$name,$paths{'REALDATA'}.$sub_dir."/");
	  	}else{
	  		mkdir($paths{'REALDATA'}.$sub_dir."/") or die "sub dir build faild......\n";
	  		move($paths{'REALDATA'}.$name,$paths{'REALDATA'}.$sub_dir."/");
	  	}
	  }
}

# 读取子目录
sub getSubdir{
	opendir (REALDATA ,$paths{'REALDATA'}) or die "open dir faild,$!";
	while (my $f =readdir REALDATA){
		if(!($f=~/^[.]+/)){
			my $tpath=$paths{'REALDATA'}.$f."/";
			if(-d $tpath){
				if($f!="BAKCUP"){
				 chdir($tpath);
				 my $verf=`find . -maxdepth 1 -type f -name "*.verf" |wc -l`;
				 if($verf ==0){
				   msg( $tpath."verf file not found......\n");	
				 }else{
				 	   if (substr($f,8,5)=='30001') {
				 	   	 chdir($tpath);
				 	   	 my $mov30001=`mv *.* $paths{'BSS_BACKUP'}`;
				 	   }else{
								if(validcount($tpath)==1){
										if(is_empty($paths{'BAKCUP'})==0){
											#print "当前目录是".getcwd."\n";
											chdir($tpath);
											my $movflag=`mv *.* $paths{'BAKCUP'}`;
											print "move finish.....\n";
									}	
				 	   	  }
				 	   }
				 }
				}
			}
		}
	}
	closedir REALDATA;
	
	chdir($paths{'REALDATA'});
	msg("STEP3::::::::::::::::listdir function finish......\n");
}


# 删除空目录
sub deleteEmpty{
	opendir (REALDATA ,$paths{'REALDATA'}) or die "open dir faild,$!";
	while (my $f =readdir REALDATA){
		if(!($f=~/^[.]+/)){
			my $tPath=$paths{'REALDATA'}.$f."/";
			if(-d $tPath){
				if($f!="BAKCUP"){
				  if(is_empty($tPath)==0){
				  		print $tPath." well delete......\n";
				  		rmdir($paths{'REALDATA'}.$f);
				  }else{
				  		print $tPath." is not empty!\n";
				  }
				}
			}
		}
	}
	closedir REALDATA;
	msg("STEP1::::::::::::::::deleteEmpty function finish......\n");
}


# 检查bakcup目录是否为空
sub is_empty {
    my ($path)=@_;
    chdir($path);
    my $count=`find . -type f |wc -l`;
    return $count;
}

# 注释方法
sub msg{
	  my ($message)=@_;
	  print " $message ";
}

# 判断目录中校验文件和数据文件数是否相等
sub validcount{
	my $flag=0;
	my ($path)=@_;
	chdir($path);
	my $count_v=`wc -l *.verf`;
	my $count_d=`ls *.dat|wc -l`;
	my @temp=split /\s+/,$count_v;
	if($temp[0]==$count_d){
		$flag=1;
	}
	#print "verf=$temp[0] :::: dat=$count_d";
	return $flag;
}

sub main(){
	while(1==1){
	    deleteEmpty();
			listdir();
			getSubdir();
			sleep(120);
	}
}

main();





=pod
my $path='/pardata/EDADATA/INTERFACE/BSS/REALDATA';
my @files=`find $path -maxdepth 1 -type f `;
foreach my $f (@files){
  print "--".$f."\n";
}
=cut
