namespace FTPDeployment.Core.Models;

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
    property Uploads:List<Upload> := new List<Upload>;


  end;

end.