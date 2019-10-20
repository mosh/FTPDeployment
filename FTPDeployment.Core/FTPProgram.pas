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



      var app := new CommandLineApplication;

      app.HelpOption;

      var lOption := app.Option('-l','List files at remote location(s)',CommandOptionType.NoValue);
      var dOption := app.Option('-d','Deploy to remote location(s)',CommandOptionType.NoValue);
      var rOption := app.Option('-r','Remove at remote location(s)',CommandOptionType.NoValue);
      var iOption := app.Option('-i','Import folder',CommandOptionType.SingleValue);
      var fOption := app.Option('-f','Deployment filename', CommandOptionType.SingleValue);

      app.OnExecute(() -> begin

        if(not fOption.HasValue)then
        begin
          Console.WriteLine('Deployment filename must be specified with -f');
          exit 0;
        end;

        var deployFilename := $'{System.Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments)}/Documents/Secrets/{fOption.Value}';

        if(not File.Exists(deployFilename))then
        begin
          Console.WriteLine($'Deployment filename {deployFilename} does not exist');
          exit;
        end;

        Console.WriteLine($'Deploymane filename is {deployFilename}');

        var deploy := JsonConvert.DeserializeObject<Deployment>(File.ReadAllText(deployFilename));

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