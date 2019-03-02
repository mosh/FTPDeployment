namespace FTPDeployment;

uses
  System,
  System.Collections.Generic,
  System.IO,
  System.Text,
  System.Threading.Tasks;

type
  FileUtil = assembly static class
  public
    class method ReadAllFileAsync(filename: String): Task<array of Byte>;
    begin
      Validate.NotNullOrEmptyOrWhiteSpace(filename, nameOf(filename));
      using file := new FileStream(filename, FileMode.Open, FileAccess.Read, FileShare.Read, 4096, true) do begin
        var buff := new Byte[file.Length];
        await file.ReadAsync(buff, 0, Integer(file.Length));
        exit buff;
      end;
    end;

    class method ReadAllTextFileAsync(filename: String): Task<String>;
    begin
      Validate.NotNullOrEmptyOrWhiteSpace(filename, nameOf(filename));
      using reader := File.OpenText(filename) do begin
        exit await reader.ReadToEndAsync();
      end;
    end;

    class method SaveAllFileAsync(filename: String; data: array of Byte): Task;
    begin
      Validate.NotNullOrEmptyOrWhiteSpace(filename, nameOf(filename));
      Validate.NotNull(data, nameOf(data));
      using file := new FileStream(filename, FileMode.Create, FileAccess.Write, FileShare.Write, 4096, true) do begin
        await file.WriteAsync(data, 0, data.Length);
      end;
    end;

    class method SaveAllTextAsync(filename: String; content: String): Task;
    begin
      Validate.NotNullOrEmptyOrWhiteSpace(filename, nameOf(filename));
      Validate.NotNull(content, nameOf(content));
      using file := new StreamWriter(filename) do begin
        await file.WriteAsync(content);
      end;
    end;

    class method Move(source: String; destination: String; overwrite: Boolean);
    begin
      if File.Exists(destination) then begin
        if overwrite then begin
          File.Copy(source, destination, true);
          File.Delete(source);
        end;
      end
      else begin
        File.Move(source, destination);
      end;
    end;

    class method MakeOld(resourceFile: String);
    begin
      Validate.NotNullOrEmptyOrWhiteSpace(resourceFile, nameOf(resourceFile));
      var oldFile := resourceFile + '_OLD';
      var oldIndex := 1;
      while File.Exists(oldFile) do
      begin
        inc(oldIndex);
        oldFile := $'{resourceFile}_OLD{oldIndex}';
      end;
      File.Move(resourceFile, oldFile);
    end;

    class method MakeValidFileName(filename: String): String;
    begin
      exit String.Join('_', filename.Split(Path.GetInvalidFileNameChars()));
    end;

  end;

end.