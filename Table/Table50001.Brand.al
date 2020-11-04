table 50001 "Brand"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Manufacturer Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Name RU"; Text[50])
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Code", "Manufacturer Code")
        {
            Clustered = true;
        }
    }
}
