#!/usr/bin/perl
use strict;
use File::Copy;
use Cwd;

=pod
      	1.����realdataĿ¼
        2.��ȡdat�ļ���verf�ļ��������ļ���������+�ӿڵ��ļ�����
        3.
=cut
my %paths=(
 'REALDATA'=>'/pardata/EDADATA/INTERFACE/BSS/REALDATA/',
 'BSS_BACKUP'=>'/pardata/EDADATA/INTERFACE/BSS/BACKUP/',
 'BAKCUP'=>'/pardata/EDADATA/INTERFACE/BSS/REALDATA/BAKCUP/'
);

# ��ȡ����Ŀ¼
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


# �����ļ����ƴ���Ŀ¼ s_20190819_30001_00_8030662.dat
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

# ��ȡ��Ŀ¼
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
				 	   }elsif(substr($f,8,5)=='30002'){
				 	   	chdir($tpath);
				 	   	 my $mov30002=`mv *.* $paths{'BSS_BACKUP'}`;
				 	   }elsif(substr($f,8,5)=='30003'){
				 	   	chdir($tpath);
				 	   	 my $mov30003=`mv *.* $paths{'BSS_BACKUP'}`;
				 	   }elsif(substr($f,8,5)=='30004'){
				 	   	chdir($tpath);
				 	   	 my $mov30004=`mv *.* $paths{'BSS_BACKUP'}`;
				 	   }elsif(substr($f,8,5)=='30005'){
				 	   	chdir($tpath);
				 	   	 my $mov30005=`mv *.* $paths{'BSS_BACKUP'}`;
				 	   }else{
								if(validcount($tpath)==1){
										if(is_empty($paths{'BAKCUP'})==0){
											#print "��ǰĿ¼��".getcwd."\n";
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


# ɾ����Ŀ¼
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


# ���bakcupĿ¼�Ƿ�Ϊ��
sub is_empty {
    my ($path)=@_;
    chdir($path);
    my $count=`find . -type f |wc -l`;
    return $count;
}

# ע�ͷ���
sub msg{
	  my ($message)=@_;
	  print " $message ";
}

# �ж�Ŀ¼��У���ļ��������ļ����Ƿ����
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