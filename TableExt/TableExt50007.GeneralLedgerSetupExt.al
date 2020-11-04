tableextension 50007 "General Ledger Setup Ext." extends "General Ledger Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Journal Template Name"; Code[10])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Journal Template Name', RUS = 'Имя шаблона журнала';
            TableRelation = "Gen. Journal Template";
        }
        field(50001; "Journal Batch Name"; Code[10])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Journal Batch Name', RUS = 'Название раздела журнала';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
    }
}