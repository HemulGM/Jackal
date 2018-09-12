program JackalGame;



{$R *.dres}

uses
  Vcl.Forms,
  Jackal.Main in 'Jackal.Main.pas' {FormMain},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Шакал (Jackal)';
  TStyleManager.TrySetStyle('Onyx Blue');
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
