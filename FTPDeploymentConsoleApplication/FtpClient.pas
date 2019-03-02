namespace FTPDeployment;

uses
  System,
  System.Globalization,
  System.IO,
  System.Net,
  System.Text.RegularExpressions,
  System.Threading.Tasks;

type
  FtpClient = public class
  private
    property Password: String read ;

    method GetFtpWebRequest(remotePath: String): FtpWebRequest;
    begin
      var request := FtpWebRequest(WebRequest.Create(String.Format('ftp://{0}:{1}/{2}', Host, Port, remotePath)));
      request.Credentials := new NetworkCredential(coalesce(Username, 'anonymous'), Password);
      request.Timeout := Timeout;
      request.ReadWriteTimeout := Timeout;
      request.KeepAlive := false;
      request.ServicePoint.ConnectionLimit := 1000;
      request.UsePassive := PassiveMode;
      request.EnableSsl := EnableSsl;
      exit request;
    end;

  public
    property Host: String read ;
    property Port: Integer read ;
    property Username: String read ;
    property Timeout: Integer read ;
    property PassiveMode: Boolean read ;
    property EnableSsl: Boolean read ;

    constructor(_host: String; _port: Integer := 21; _username: String := nil;
      _password: String := nil; _timeout: Integer := -1;
      _passiveMode: Boolean := true; _enableSsl: Boolean := false);
    begin
      Validate.NotNullOrEmptyOrWhiteSpace(_host, nameOf(_host));
      Validate.Positive(_port, nameOf(_port));
      self.Host := _host;
      Port := _port;
      Username := _username;
      Password := _password;
      Timeout := _timeout;
      PassiveMode := _passiveMode;
      EnableSsl := _enableSsl;
    end;

    method Upload(localFileName: String; remoteFileName: String := nil): Task;
    begin
      Validate.NotNullOrEmptyOrWhiteSpace(localFileName, nameOf(localFileName));
      remoteFileName := coalesce(remoteFileName, Path.GetFileName(localFileName));

      var request := GetFtpWebRequest(remoteFileName);
      request.Method := WebRequestMethods.Ftp.UploadFile;
      request.ContentLength := new FileInfo(localFileName).Length;

      using requestStream := await request.GetRequestStreamAsync do
      begin
        using fs := new FileStream(localFileName, FileMode.Open) do
        begin
          await fs.CopyToAsync(requestStream);
        end;
      end;

      using await request.GetResponseAsync do
      begin

      end;

    end;



    method Upload(stream: Stream; remoteFileName: String): Task;
    begin
      Validate.NotNull(stream, nameOf(stream));
      Validate.NotNullOrEmptyOrWhiteSpace(remoteFileName, nameOf(remoteFileName));
      var request := GetFtpWebRequest(remoteFileName);
      request.Method := WebRequestMethods.Ftp.UploadFile;
      request.ContentLength := stream.Length;
      using requestStream := await request.GetRequestStreamAsync() do
      begin
        await stream.CopyToAsync(requestStream);
      end;
      using requestStream := await request.GetRequestStreamAsync() do
      begin
        await stream.CopyToAsync(requestStream);
      end;

      using await request.GetResponseAsync() do
      begin

      end;
    end;


    method Upload(buffer: array of Byte; remoteFileName: String): Task;
    begin
      Validate.NotNull(buffer, nameOf(buffer));
      Validate.NotNullOrEmptyOrWhiteSpace(remoteFileName, nameOf(remoteFileName));
      var request := GetFtpWebRequest(remoteFileName);
      request.Method := WebRequestMethods.Ftp.UploadFile;
      request.ContentLength := buffer.Length;
      using requestStream := await request.GetRequestStreamAsync() do begin
        await requestStream.WriteAsync(buffer, 0, buffer.Length);
      end;
      using  await request.GetResponseAsync() do
      begin
      end;
    end;

    method Download(remoteFileName: String; localFileName: String): Task;
    begin
      Validate.NotNullOrEmptyOrWhiteSpace(remoteFileName, nameOf(remoteFileName));
      Validate.NotNullOrEmptyOrWhiteSpace(localFileName, nameOf(localFileName));
      if Path.IsPathRooted(remoteFileName) then begin
        raise new ArgumentException('Must be a relative file path', nameOf(remoteFileName));
      end;
      var request := GetFtpWebRequest(remoteFileName);
      request.Method := WebRequestMethods.Ftp.DownloadFile;
      using response := FtpWebResponse(await request.GetResponseAsync()) do begin
        using responseStream := response.GetResponseStream() do
          using fs := new FileStream(localFileName, FileMode.Create) do
            await responseStream.CopyToAsync(fs);
      end;
    end;

    method Download(remoteFileName: String): Task<Stream>;
    begin
      Validate.NotNullOrEmptyOrWhiteSpace(remoteFileName, nameOf(remoteFileName));
      if Path.IsPathRooted(remoteFileName) then begin
        raise new ArgumentException('Must be a relative file path', nameOf(remoteFileName));
      end;
      var request := GetFtpWebRequest(remoteFileName);
      request.Method := WebRequestMethods.Ftp.DownloadFile;
      using response := FtpWebResponse(await request.GetResponseAsync()) do begin
        using responseStream := response.GetResponseStream() do begin
          var ms := new MemoryStream();
          await responseStream.CopyToAsync(ms);
          ms.Seek(0, SeekOrigin.Begin);
          exit ms;
        end;
      end;
    end;

    method ListDirectory(remoteDirectory: String := nil): Task<array of String>;
    begin
      if assigned(remoteDirectory) then begin
        remoteDirectory := remoteDirectory.Replace(#92, #47);
        if not remoteDirectory.EndsWith('/') then begin
          remoteDirectory := remoteDirectory + '/';
        end;
      end;
      var request := GetFtpWebRequest(remoteDirectory);
      request.Method := WebRequestMethods.Ftp.ListDirectory;
      using response := FtpWebResponse(await request.GetResponseAsync()) do begin
        using responseStream := response.GetResponseStream() do
          using streamReader := new StreamReader(responseStream) do begin
            var responseContent := await streamReader.ReadToEndAsync();
            exit responseContent.Split([#13#10, #13, #10], StringSplitOptions.RemoveEmptyEntries);
          end;
      end;
    end;

    method ListDirectoryDetails(remoteDirectory: String := nil): Task<array of String>;
    begin
      if assigned(remoteDirectory) then begin
        remoteDirectory := remoteDirectory.Replace(#92, #47);
        if not remoteDirectory.EndsWith('/') then begin
          remoteDirectory := remoteDirectory + '/';
        end;
      end;
      var request := GetFtpWebRequest(remoteDirectory);
      request.Method := WebRequestMethods.Ftp.ListDirectoryDetails;
      using response := FtpWebResponse(await request.GetResponseAsync()) do begin
        using responseStream := response.GetResponseStream() do
          using streamReader := new StreamReader(responseStream) do begin
            var responseContent := await streamReader.ReadToEndAsync();
            exit responseContent.Split([#13#10, #13, #10], StringSplitOptions.RemoveEmptyEntries);
          end;
      end;
    end;

    method Rename(oldRemoteFileName: String; newRemoteFileName: String): Task;
    begin
      var request := GetFtpWebRequest(oldRemoteFileName);
      request.Method := WebRequestMethods.Ftp.Rename;
      request.RenameTo := newRemoteFileName;
      using  await request.GetResponseAsync() do
      begin
      end;
    end;

    method MakeDirectory(remoteDirectoryName: String): Task;
    begin
      var request := GetFtpWebRequest(remoteDirectoryName);
      request.Method := WebRequestMethods.Ftp.MakeDirectory;
      using  await request.GetResponseAsync() do
      begin
      end;
    end;

    method RemoveDirectory(remoteDirectoryName: String): Task;
    begin
      var request := GetFtpWebRequest(remoteDirectoryName);
      request.Method := WebRequestMethods.Ftp.RemoveDirectory;
      using  await request.GetResponseAsync() do
      begin
      end;
    end;

    method Delete(remoteFileName: String): Task;
    begin
      var request := GetFtpWebRequest(remoteFileName);
      request.Method := WebRequestMethods.Ftp.DeleteFile;
      using  await request.GetResponseAsync() do
      begin
      end;
    end;

    method GetLastModifiedTimestamp(remoteFileName: String): Task<DateTime>;
    begin
      var request := GetFtpWebRequest(remoteFileName);
      request.Method := WebRequestMethods.Ftp.GetDateTimestamp;
      request.UseBinary := false;

      using response:FtpWebResponse := await request.GetResponseAsync do
      begin

        using  reader := new StringReader(response.StatusDescription) do
        begin
          var DateString := reader.ReadLine.Substring(4);
          exit DateTime.ParseExact(DateString, "yyyyMMddHHmmss", CultureInfo.InvariantCulture.DateTimeFormat);
        end;

      end;
    end;

    method GetFileSize(remoteFileName: String): Task<Int64>;
    begin
      var request := GetFtpWebRequest(remoteFileName);
      request.Method := WebRequestMethods.Ftp.GetFileSize;

      using response := await request.GetResponseAsync() do
      begin
        var value := response.ContentLength.ToString;
        using responseStream := response.GetResponseStream() do
        begin
          using streamReader := new StreamReader(responseStream) do begin
            var responseContent := await streamReader.ReadToEndAsync();
            exit Convert.ToInt64(value);
          end;
        end;
      end;
    end;

  end;

end.