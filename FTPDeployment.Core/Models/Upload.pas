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
    property Files:List<String> := new List<String>;
  end;

end.