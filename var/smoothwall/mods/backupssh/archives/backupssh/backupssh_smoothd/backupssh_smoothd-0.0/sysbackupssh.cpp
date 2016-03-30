/* Sysbackupssh Module for the SmoothWall SUIDaemon                           */
/* Contains functions relating to starting/restarting ntp daemon         */
/* (c) 2007 SmoothWall Ltd                                                */
/* ----------------------------------------------------------------------  */
/* Original Author  : Lawrence Manning                                     */
/* Translated to C++: M. W. Houston                                        */

/* include the usual headers.  iostream gives access to stderr (cerr)     */
/* module.h includes vectors and strings which are important              */
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include <iostream>
#include <fstream>
#include <fcntl.h>
#include <syslog.h>
#include <signal.h>

#include "module.h"
#include "ipbatch.h"
#include "setuid.h"

extern "C" {
	int load( std::vector<CommandFunctionPair> &  );
	int backupssh_transfer(std::vector<std::string> & parameters, std::string & response);
}

int load( std::vector<CommandFunctionPair> & pairs )
{
	/* CommandFunctionPair name( "command", "function" ); */
	CommandFunctionPair backupssh_transfer_function("backupsshtransfer", "backupssh_transfer", 0, 0);

	pairs.push_back(backupssh_transfer_function);

	return 0;
}

int backupssh_transfer(std::vector<std::string> & parameters, std::string & response)
{
   int error = 0;
   response = "backupssh: transferring archive...";
      error = simplesecuresysteml("/var/smoothwall/mods/backupssh/etc/script.sh", NULL);
      if (!error)
         response = "backupssh: transfer successful.";
      else
         response = "backupssh: unable to transfer archive";
	
   return 0;
}
