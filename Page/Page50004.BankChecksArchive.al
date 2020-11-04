page 50004 "Bank Checks Archive"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "Bank Check Journal Line";
    AccessByPermission = tabledata "Bank Check Journal Line" = rimd;
    SourceTableView = where(Status = filter(<> New));
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                }
                field("Bank Check Date"; Rec."Bank Check Date")
                {
                    ApplicationArea = All;
                }
                field("Bank Check No."; Rec."Bank Check No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Last Modified DateTime"; Rec."Last Modified DateTime")
                {
                    ApplicationArea = All;
                    // Visible = false;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ReturnToJournal)
            {
                ApplicationArea = All;
                Image = Approval;
                CaptionML = ENU = 'Return to Journal', RUS = 'Вернуть в журнал';

                trigger OnAction()
                var
                    _BankCheck: Record "Bank Check Journal Line";
                begin
                    CurrPage.SetSelectionFilter(_BankCheck);
                    if _BankCheck.FindSet(false, false) then
                        repeat
                            _BankCheckMgt.SetBankCheckStatus(_BankCheck, _BankCheck.Status::New);
                        until _BankCheck.Next() = 0;
                end;
            }
        }
    }

    var
        _BankCheckMgt: Codeunit "Bank Checks Mgt.";
}