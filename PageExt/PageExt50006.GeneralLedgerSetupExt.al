pageextension 50006 "General Ledger Setup Ext." extends "General Ledger Setup"
{
    layout
    {
        // Add changes to page layout here
        addafter(Application)
        {
            group(BankChecks)
            {
                CaptionML = ENU = 'Bank Checks', RUS = 'Банковские Чеки';

                field("Journal Template Name"; "Journal Template Name")
                {
                    ApplicationArea = All;
                    // Importance = Additional;
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = All;
                    // Importance = Additional;
                }
            }
        }
        addafter(Application)
        {
            group(eCommerce)
            {
                field("Transfer Items Job Queue Only"; "Transfer Items Job Queue Only")
                {
                    ApplicationArea = All;
                    // Importance = Additional;
                }
            }
        }
    }
}