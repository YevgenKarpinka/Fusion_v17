page 50011 "Sales Lines List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Sales Line";
    AccessByPermission = tabledata "Sales Line" = rimd;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                Editable = false;
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;

                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;

                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;

                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;

                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Delete Record(s)")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Delete Record(s)', RUS = 'Удалить строку(ки)';

                trigger OnAction()
                var
                    _salesLine: Record "Sales Line";
                begin
                    CurrPage.SetSelectionFilter(_salesLine);
                    _salesLine.DeleteAll();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        salesHeader: Record "Sales Header";
        salesLine: Record "Sales Line";
    begin
        salesLine.FindSet(false, false);
        repeat
            if not salesHeader.Get(salesLine."Document Type", salesLine."Document No.") then begin
                tempSalesLine.TransferFields(salesLine);
                tempSalesLine.Insert();
            end;
        until salesLine.Next() = 0;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Found: Boolean;
    begin
        // RunOnTempRec := not tempSalesLine.IsEmpty;
        RunOnTempRec := true;
        if RunOnTempRec then begin
            tempSalesLine.Copy(Rec);
            Found := tempSalesLine.Find(Which);
            if Found then
                Rec := tempSalesLine;
            exit(Found);
        end;
        exit(Rec.Find(Which));
    end;

    var
        tempSalesLine: Record "Sales Line" temporary;
        RunOnTempRec: Boolean;
}