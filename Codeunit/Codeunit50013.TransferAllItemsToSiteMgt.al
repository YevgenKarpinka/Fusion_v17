codeunit 50013 "Transfer All Items To Site Mgt"
{
    trigger OnRun()
    begin
        TransferItemsToSite.AddAllItemsForTransferToSite();
    end;

    var
        TransferItemsToSite: Codeunit "Transfer Items To Site Mgt";
}