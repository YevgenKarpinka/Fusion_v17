pageextension 50016 "Customer Card Ext." extends "Customer Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Customized Calendar")
        {
            field("Posting Type Shipment Cost"; Rec."Posting Type Shipment Cost")
            {
                ApplicationArea = All;
            }
            field("Sales No. Shipment Cost"; Rec."Sales No. Shipment Cost")
            {
                ApplicationArea = All;
            }
        }
    }
}