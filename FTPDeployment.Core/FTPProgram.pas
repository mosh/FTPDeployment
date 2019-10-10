namespace FTPDeployment.Core;

uses
  FTPDeployment.Core.Models,
  McMaster.Extensions.CommandLineUtils,
  Newtonsoft.Json,
  System.IO;

type
  FTPProgram = public class
  public
    class method Main(args: array of String): Int32;
    begin

      var deployFilename := $'{System.Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments)}/Documents/Secrets/iSailed.Deployment';

      if(not File.Exists(deployFilename))then
      begin
        raise new Exception($'Deployment File {deployFilename} does not exist');
      end;
      var deploy := JsonConvert.DeserializeObject<Deployment>(File.ReadAllText(deployFilename));

      var app := new CommandLineApplication;

      app.HelpOption;

      var lOption := app.Option('-l','List files at remote location(s)',CommandOptionType.NoValue);
      var dOption := app.Option('-d','Deploy to remote location(s)',CommandOptionType.NoValue);
      var rOption := app.Option('-r','Remove at remote location(s)',CommandOptionType.NoValue);

      app.OnExecute(() -> begin


        if(lOption.HasValue)then
        begin
          try
            Console.WriteLine('Listing...');
            deploy.List.Wait;
          except
            on E:Exception do
            begin
              Console.WriteLine($'Exception {E.Message} listing');
            end;
          end;
        end;
        if(rOption.HasValue)then
        begin
          try
            Console.WriteLine('Removing...');
            deploy.RemoveContent.Wait;
          except
            on E:Exception do
            begin
              Console.WriteLine($'Exception {E.Message} removing');
            end;
          end;
        end;
        if(dOption.HasValue)then
        begin
          try
            Console.WriteLine('Deploying...');
            deploy.Upload.Wait;
          except
            on E:Exception do
            begin
              Console.WriteLine($'Exception {E.Message} deploying');
            end;
          end;
        end;


        exit 0;
      end);

      exit app.Execute(args);
    end;

  end;
end.