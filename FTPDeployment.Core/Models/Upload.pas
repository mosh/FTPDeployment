namespace FTPDeployment.Core.Models;

uses
  System.Collections.Generic;

type
  Upload = public class
  private
  protected
  public
    property LocalFolder:String;
    property RemoteFolder:String;
    property Files:List<File> := new List<File>;
  end;

end.