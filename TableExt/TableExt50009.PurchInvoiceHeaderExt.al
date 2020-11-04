tableextension 50009 "Purch. Invoice Header Ext." extends "Purch. Inv. Header"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "IC Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'IC Document No.', RUS = 'МФ Документ Но.';
        }
    }
}