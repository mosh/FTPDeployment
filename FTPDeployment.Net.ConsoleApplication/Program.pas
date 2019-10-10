namespace FTPDeployment.Net.ConsoleApplication;

uses
  FTPDeployment.Core;

type
  Program = class
  public

    class method Main(args: array of String): Int32;
    begin
      exit FTPProgram.Main(args);
    end;

  end;

end.