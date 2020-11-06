pageextension 50020 "Bin Content Ext." extends "Bin Content"
{
    layout
    {
        addfirst(Control1)
        {
            field("Lot No."; "Lot No.")
            {
                ApplicationArea = All;
            }
        }
    }
}