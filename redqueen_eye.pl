#! /usr/bin/perl
use strict;
use Net::FTP;
use POSIX;
use Net::Cmd;
use File::Basename;
use File::Copy;
use Data::Dumper;



#����Զ��·��
my %path=('target'=>'/pardata/EDADATA/INTERFACE/BSS/REALDATA/',
'record'=>'/pardata/EDASCRIPT/publisher0/EYE/'
);


##################################################################
sub getFileName # ͨ��ȫ·����ȡ�ļ���
##################################################################
{
	my ($path0)=@_;
	my $dirname=dirname($path0);
	my $filename=substr($path0,length($dirname)+1);
	return $filename;
}


#################################################################
sub write_record #д����־
#################################################################                  
{
	 my($str)=@_;
	 my $logfile=$path{'record'}."eye.log";
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
	 my $logfile=$path{'record'}."eye.log";
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
  1.�鿴Ŀ¼
  2.��Ŀ¼�������ļ���¼����¼�ļ���
=cut
   while(1==1){
      msg("honghou day:scan file ");
      my @dir_files = <$path{'target'}*>;
      foreach my $f (@dir_files){
      	if (!(-d $f)){
      		my $fn=getFileName($f);
	      	if(isExeRecord($fn)==0){
	      		write_record($fn);
	      	}
      	}
     	}
			sleep(60);
	 }
}

main();
