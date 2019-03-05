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

      var deployFilename := '/Users/JohnMoshakis/Documents/Secrets/iSailed.Deployment';

      if(not File.Exists(deployFilename))then
      begin
        raise new Exception($'Deployment File {deployFilename} does not exist');
      end;
      var deploy := JsonConvert.DeserializeObject<Deployment>(File.ReadAllText(deployFilename));


      if((assigned(args)) and (args.Length>0))then
      begin
        try
          List(deploy).Wait;
        except
          on E:Exception do
          begin
            Console.WriteLine($'Exception {E.Message} Listing');
          end;
        end;

      end
      else
      begin

        try
          Upload(deploy).Wait;
        except
          on E:Exception do
          begin
            Console.WriteLine($'Exception {E.Message} Listing');
          end;
        end;

      end;

    end;


    class method List(deploy:Deployment):Task;
    begin
      var client := new FtpClient(deploy.Host,21,deploy.Username, deploy.Password);

      var files := await client.ListDirectory(deploy.RemoteFolder);

      for each filename in files do
      begin
        var remoteFilename := $'{deploy.RemoteFolder}/{filename}';
        try
          var dateTime := await client.GetLastModifiedTimestamp(remoteFilename);
          Console.WriteLine($'filename {filename} Last Modified {dateTime}');
        except
          on E:Exception do
          begin
            Console.WriteLine($'Exception {E.Message}');
          end;
        end;
      end;

    end;

    class method Upload(deploy:Deployment):Task;
    begin

      var client := new FtpClient(deploy.Host,21,deploy.Username, deploy.Password);

      var remoteFiles := await client.ListDirectory(deploy.RemoteFolder);

      for each filename in deploy.Files do
      begin

        var remoteFilename := $'{deploy.RemoteFolder}/{filename}';

        if(remoteFiles.Contains(filename))then
        begin

          var dateTime := await client.GetLastModifiedTimestamp(remoteFilename);
          var filesize := await client.GetFileSize(remoteFilename);

          Console.WriteLine($'filename {filename} Last Modified {dateTime} Size {filesize}');
        end;

        var localFilename := Path.Combine(deploy.LocalFolder,filename);

        if(File.Exists(localFilename))then
        begin
          await client.Upload(localFilename,remoteFilename);
        end;

      end;

    end;

  end;


end.