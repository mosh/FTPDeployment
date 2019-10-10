namespace FTPDeployment.Core;

uses
  System,
  System.Runtime.Serialization;

type
  [Serializable]
  FtpReplyException = assembly class(Exception)
  protected
    constructor(info: SerializationInfo; context: StreamingContext);
    begin
      inherited constructor (info, context);
    end;
  public

    constructor;
    begin
    end;

    constructor(message: String);
    begin
      inherited constructor (message);
    end;
    constructor(message: String; innerException: Exception);
    begin
      inherited constructor (message, innerException);
    end;
  end;

end.