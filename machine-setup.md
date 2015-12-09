### Quant places of interest


### Getting your machine setup

A useful tool to have is [Virtual CDROM Control Panel](https://www.microsoft.com/en-us/download/details.aspx?id=38780) that allows you to mount an ISO file without extracting it

#### Setting up Visual Studio
We use Visual Studio 2013 Professional. You can get a copy of the installation files from [here]()

Which features to install:
* MFC for VC++
* Office applications
* Web development
* Silverlight


Also, you'll want to install some plugins.

* [Power commands](https://visualstudiogallery.msdn.microsoft.com/e5f41ad9-4edc-4912-bca3-91147db95b99/)
* [Productivity Power Tools 2013](https://visualstudiogallery.msdn.microsoft.com/dbcb8670-889e-4a54-a226-a48a15e4cace)

Themes
I've had a number of requests for my Visual Studio theme over the years, so I will provide it here.

1. First, download and install the theme fonts. One is called Dina, which is the font I use for the output console. The other is called Envy Code R and it is great. There are two variants. The VS version uses Italic as Bold.
2. Then download the theme itself, saving it somewhere convenient for importing into Visual Studio.
3. In VS: Tools -> Import and Export Settings...
4. Enjoy.

#### Setting up SQL Server

We use SQL Server 2014 Standard Edition (64-bit). You can get a copy of the installation files form over <a href="\\orbis.co.uk\London\Source\MSDN\SQL Server 2014 Standard">here</a> 

To avoid confusion/conflicts you may want to uninstall SQL Server Express that came with your Visual Studio installation before installing SQL Server.  SQL Server Express appears as Microsoft SQL Server... in add/remove programs; don't expect to see "Express" in the name anywhere.  There are a number of items listed, all starting with Microsoft SQL Server -- remove them.
If you wish to deploy the server locally, you will need to have an instance of SQL Server running on your local machine.  Setup is quite straightforward:

Make sure you install the "SQL Server Data Tools"

1. Copy and unzi the SQL Server 2008 ISO to your PC. 
2. Run the setup.
3. Continue with the usual (next/OK) until you get the feature selection screen.
4. Install at minimum the following:
    * Database Engine
    * Management Tools - complete
5. Continue until you reach instance configuration.
6. Select default instance.  Continue until you reach server configuration.
7. Make sure that under collation **SQL_Latin1_General_CP1_CI_AS** is selected.
8. Under account name, choose **NT Authority\System** for the **Agent** and **Database Engine**.  Hit Next.
9. Use Windows authentication mode. Make sure your logged in using the domain and press add current user. You will also want to add your local user, to do this press add and change the location to the name of your computer and in the object window type your username. 
10. Complete the installation.


Further configuration:

* Open Start menu -> All Programs -> Microsoft SQL Server 2008 R2 -> Configuration Tools -> SQL Server Configuration Manager
* From left side view of SQL Server Configration Manager, expand SQL Server Network Configuration, and select Protocols for MSSQLSERVER

Named pipes
Icon
If you have trouble deploying the database, you might need to enable Named Pipes as a connection method. 

Remote access
Icon
If you want to enable remote access to your database, make sure TCP/IP is also enabled.
At the same time, make sure the SQL Server Browser service is running on the machines as well. Otherwise you will get the error similar to:
A network related or instance specific error occurred, while establishing a connection to SQL Server. The server was not found or was not accessible. Verify that the instance name is correct and that SQL server is configured to allow remote connections.(provider: SQL Network Inrerfaces, error:26 - Error Locating Server/Insatance Specified) (Microsoft SQL Server)


Fixing Collation Conflicts
If you find you have an installation of SQL Server with the wrong default collation, please drop all user databases, and run the following from the SQL installation directory:
```
Setup
/QUIET /ACTION=REBUILDDATABASE /INSTANCENAME=MSSQLSERVER
/SQLSYSADMINACCOUNTS=BUILTIN\Administrators %UserDomain%\%Username%
/SQLCOLLATION=SQL_Latin1_General_CP1_CI_AS
```

#### Other goodies
* Theme fonts (Envy Code R, Dina) (These are specific to a theme used by Colin, but Envy Code R is a fantastic programming typeface IMHO)
* ConsoleZ : Great shell wrapper.
* Tweetdeck
* CodeBank (zeraha.org)
* e-texteditor
* Paint.NET
* FileZilla
* KeePass
* Microsoft Expression Studio
* SharpKeys
* Skype
* Rapid Environment Editor
* Cropper
* Actual Multiple Monitors
* UnxUtils : Handful of common GNU tools for Windows.