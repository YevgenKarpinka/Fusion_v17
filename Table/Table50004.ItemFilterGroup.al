table 50004 "Item Filter Group"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            DataClassification = SystemMetadata;
            TableRelation = Item;
        }
        field(2; "Filter Group"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Filter Value"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Filter Group RUS"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Filter Value RUS"; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Item No.", "Filter Group", "Filter Value")
        {
            Clustered = true;
        }
    }
}