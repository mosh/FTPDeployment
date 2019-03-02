namespace FTPDeployment;

uses
  Newtonsoft.Json,
  FTPDeployment,
  System.IO,
  System.Linq,
  System.Threading.Tasks;

type
  Program = class
  public
    class method Main(args: array of String): Int32;
    begin

      DoIt.Wait;

    end;


    class method DoIt:Task;
    begin

      var deployFilename := '/Users/JohnMoshakis/Documents/Secrets/iSailed.Deployment';

      if(not File.Exists(deployFilename))then
      begin
        raise new Exception($'Deployment File {deployFilename} does not exist');
      end;

      var deploy := JsonConvert.DeserializeObject<Deployment>(File.ReadAllText(deployFilename));


      var client := new FtpClient(deploy.Host,21,deploy.Username, deploy.Password);



      for each filename in deploy.Files do
      begin

        var remoteFilename := $'{deploy.RemoteFolder}/{filename}';

        var dateTime := await client.GetLastModifiedTimestamp(remoteFilename);
        var filesize := await client.GetFileSize(remoteFilename);

        Console.WriteLine($'filename {filename} Last Modified {dateTime} Size {filesize}');

        var localFilename := Path.Combine(deploy.LocalFolder,filename);

        if(File.Exists(localFilename))then
        begin
          await client.Upload(localFilename,remoteFilename);
        end;

      end;

    end;

  end;


end.