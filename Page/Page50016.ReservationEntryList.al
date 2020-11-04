page 50016 "Reservation Entry List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = "Reservation Entry";
    CaptionML = ENU = 'Reservation Entry List';

    layout
    {
        area(Content)
        {
            repeater(ReservationEntryList)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;
                }
                field("Source Ref. No."; Rec."Source Ref. No.")
                {
                    ApplicationArea = All;
                }
                field("Reservation Status"; Rec."Reservation Status")
                {
                    ApplicationArea = All;
                }
                field("Item Tracking"; Rec."Item Tracking")
                {
                    ApplicationArea = All;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}