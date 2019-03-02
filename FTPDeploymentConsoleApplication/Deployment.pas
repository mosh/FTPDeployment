namespace FTPDeployment;

uses
  System.Collections.Generic;

type
  Deployment = public class
  private
  protected
  public
    property Username:String;
    property Password:String;
    property Host:String;
    property LocalFolder:String;
    property RemoteFolder:String;
    property Files:List<String> := new List<String>;
  end;

end.