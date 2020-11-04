page 50013 "Item Tracking Entries FactBox"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = History;
    SourceTable = "Item Ledger Entry";
    CaptionML = ENU = 'Item Tracking Entries', RUS = 'Операции трассировки товара';
    AccessByPermission = tabledata "Item Ledger Entry" = r;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater("Item Tracking List")
            {
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = All;
                }
                // field(Quantity; Quantity)
                // {
                //     ApplicationArea = All;
                // }
                // field("Serial No."; "Serial No.")
                // {
                //     ApplicationArea = All;
                // }
                // field("Location Code"; "Location Code")
                // {
                //     ApplicationArea = All;
                // }
                // field("Item No."; "Item No.")
                // {
                //     ApplicationArea = All;
                // }
                // field("Document No."; "Document No.")
                // {
                //     ApplicationArea = All;
                // }
                // field("Document Date"; "Document Date")
                // {
                //     ApplicationArea = All;
                // }
            }
        }
    }

    // trigger OnAfterGetRecord()
    // begin
    //     with ItemLedgerEntry do begin
    //         set
    //     end;
    // end;

    // var
    //     Item:Record Item;
    //     ItemLedgerEntry: Record "Item Ledger Entry";
}