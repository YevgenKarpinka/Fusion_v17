tableextension 50017 "Location Ext." extends Location
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Create Move"; Boolean)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Create Move', RUS = 'Создать передвижение';
        }
    }
}