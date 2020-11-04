page 50022 "Whse. Item Tracking Line"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Whse. Item Tracking Line";

    layout
    {
        area(Content)
        {
            repeater(repeaterName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;

                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;

                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;

                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;

                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;

                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;

                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;

                }
                field("Quantity Handled (Base)"; Rec."Quantity Handled (Base)")
                {
                    ApplicationArea = All;

                }
                field("Qty. to Handle (Base)"; Rec."Qty. to Handle (Base)")
                {
                    ApplicationArea = All;

                }
                field("Put-away Qty. (Base)"; Rec."Put-away Qty. (Base)")
                {
                    ApplicationArea = All;

                }
                field("Pick Qty. (Base)"; Rec."Pick Qty. (Base)")
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
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}