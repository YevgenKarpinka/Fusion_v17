table 50007 "Item Transfer Site"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            DataClassification = SystemMetadata;
            CaptionML = ENU = 'Item No.',
                        RUS = 'Товар Но.';
        }
        field(2; "Description"; Text[100])
        {
            CaptionML = ENU = 'Description',
                        RUS = 'Описание';
            FieldClass = FlowField;
            CalcFormula = Lookup(Item.Description where("No." = field("Item No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
        }
    }

}