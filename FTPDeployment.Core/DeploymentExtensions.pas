namespace FTPDeployment.Core;

uses
  FTPDeployment.Core.Models,
  System,
  System.IO,
  System.Linq,
  System.Threading.Tasks;

type
  DeploymentExtensions = public extension class(Deployment)
  private
    class method MetaForFilename(client:FtpClient; remoteFilename:String; prependMessage:String):Task;
    begin
      var dateTime := await client.GetLastModifiedTimestamp(remoteFilename);
      var filesize := await client.GetFileSize(remoteFilename);
      Console.WriteLine($'{prependMessage} filename {remoteFilename} Last Modified {dateTime} Size {filesize}');
    end;

  public

    method RemoveContent:Task;
    begin
      var client := new FtpClient(self.Host,21,self.Username, self.Password);

      for each upload in self.Uploads do
      begin

        var files := await client.ListDirectory(upload.RemoteFolder);

        for each filename in files do
          begin
          var remoteFilename := $'{upload.RemoteFolder}/{filename}';
          try
            client.Delete(remoteFilename);
            Console.WriteLine($'{filename} was removed');
          except
            on E:Exception do
            begin
              Console.WriteLine($'Exception {E.Message}');
            end;
          end;
        end;

      end;

    end;


    method List:Task;
    begin
      var client := new FtpClient(self.Host,21,self.Username, self.Password);

      for each upload in self.Uploads do
      begin

        var files := await client.ListDirectory(upload.RemoteFolder);

        for each filename in files do
          begin
          var remoteFilename := $'{upload.RemoteFolder}/{filename}';
          try
            var dateTime := await client.GetLastModifiedTimestamp(remoteFilename);
            Console.WriteLine($'{filename} Last Modified {dateTime}');
          except
            on E:Exception do
            begin
              Console.WriteLine($'Exception {E.Message}');
            end;
          end;
        end;
      end;

    end;

    method Upload:Task;
    begin

      var client := new FtpClient(self.Host,21,self.Username, self.Password);

      for each upload in self.Uploads do
        begin

        var remoteFiles := await client.ListDirectory(upload.RemoteFolder);

          for each filename in upload.Files do
            begin

            var remoteFilename := $'{upload.RemoteFolder}/{filename}';

            if(remoteFiles.Contains(filename))then
            begin
              await MetaForFilename(client, remoteFilename,'Current');
            end;

            var localFilename := Path.Combine(upload.LocalFolder,filename);

            if(File.Exists(localFilename))then
            begin
              await client.Upload(localFilename,remoteFilename);

              await MetaForFilename(client, remoteFilename,'After upload');
            end
            else
            begin
              Console.WriteLine($'Local file {localFilename} does not exist');
            end;

          end;
        end;

    end;

  end;
end.