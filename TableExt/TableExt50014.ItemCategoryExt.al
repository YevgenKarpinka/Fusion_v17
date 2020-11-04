tableextension 50014 "Item Category Ext." extends "Item Category"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Description RU"; Text[100])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Description RU', RUS = 'Описание РУ';
        }
    }
}
