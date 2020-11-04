codeunit 50005 "Config Progress Bar"
{

    trigger OnRun()
    begin

    end;

    PROCEDURE Init(NewMaxCount: Integer; NewStepCount: Integer; WindowTitle: Text);
    BEGIN
        if not GuiAllowed then exit;
        Counter := 0;
        MaxCount := NewMaxCount;
        IF NewStepCount = 0 THEN
            NewStepCount := 1;
        StepCount := NewStepCount;

        Window.Open(Text000 + Text001 + Text002);
        Window.Update(1, Format(WindowTitle));
        Window.Update(3, 0);
    END;


    PROCEDURE Update(WindowText: Text);
    BEGIN
        if not GuiAllowed then exit;
        IF WindowText <> '' THEN BEGIN
            Counter := Counter + 1;
            IF Counter MOD StepCount = 0 THEN BEGIN
                Window.Update(2, Format(WindowText));
                IF MaxCount <> 0 THEN
                    Window.Update(3, Round(Counter / MaxCount * 10000, 1));
            END;
        END;
    END;

    [TryFunction]
    PROCEDURE UpdateCount(WindowText: Text; Count: Integer);
    BEGIN
        if not GuiAllowed then exit;
        IF WindowText <> '' THEN BEGIN
            IF LastWindowText = WindowText THEN
                WindowTextCount += 1
            ELSE
                WindowTextCount := 0;
            LastWindowText := WindowText;
            Window.Update(2, PadStr(WindowText + ' ', STRLEN(WindowText) + WindowTextCount, '.'));
            IF MaxCount <> 0 THEN
                Window.Update(3, Round((MaxCount - Count) / MaxCount * 10000, 1));
        END;
    END;

    PROCEDURE Close();
    BEGIN
        if not GuiAllowed then exit;
        Window.Close();
    END;

    var
        Window: Dialog;
        Text000: TextConst ENU = '#1##################\\';
        Text001: TextConst ENU = '#2##################\';
        MaxCount: Integer;
        Text002: TextConst ENU = '@3@@@@@@@@@@@@@@@@@@\';
        StepCount: Integer;
        Counter: Integer;
        LastWindowText: Text;
        WindowTextCount: Integer;
}