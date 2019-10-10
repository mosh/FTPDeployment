namespace FTPDeployment.Core;

uses
  System,
  System.Collections.Generic,
  System.Text;

type
  Validate = assembly class
  public
    class method NotNull(value: Object; parameterName: String; field: String := nil);
    begin
      if value = nil then begin
        raise new ArgumentNullException(parameterName + (if field = nil then (String.Empty) else ('.' + field)));
      end;
    end;

    class method NotNullOrEmptyOrWhiteSpace(value: String; parameterName: String; field: String := nil);
    begin
      if value = nil then
      begin
        raise new ArgumentNullException(parameterName + (if field = nil then (String.Empty) else ('.' + field)));
      end;
      if String.IsNullOrWhiteSpace(value) then
      begin
        raise new ArgumentException(String.Format("Parameter can't be an empty or whitespace string{0}"), parameterName + (if field = nil then (String.Empty) else ('.' + field)));
      end;
    end;

    class method Positive(value: Integer; parameterName: String; field: String := nil);
    begin
      if value ≤ 0 then
      begin
        raise new ArgumentException(String.Format('Parameter must be greater than 0{0}'), parameterName + (if field = nil then (String.Empty) else ('.' + field)));
      end;
    end;

    class method PositiveOrZero(value: Integer; parameterName: String; field: String := nil);
    begin
      if value < 0 then
      begin
        raise new ArgumentException(String.Format('Parameter must be greater than or equal to 0{0}'), parameterName + (if field = nil then (String.Empty) else ('.' + field)));
      end;
    end;

  end;

end.