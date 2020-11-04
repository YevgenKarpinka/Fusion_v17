tableextension 50000 "Manufacturer Ext." extends Manufacturer
{
    fields
    {
        // Add changes to table fields here
        field(50000; Address; Text[200])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Address', RUS = 'Адрес';
        }
        field(50001; "Name RU"; Text[50])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Name RU', RUS = 'Имя русское';
        }
    }
}
