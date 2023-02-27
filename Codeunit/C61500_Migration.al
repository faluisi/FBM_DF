codeunit 61500 FBM_Migration_DF
{
    var
        comp: record Company;
        Termsconditions_old: record TermsConditions;
        Termsconditions_new: record FBM_TermsConditions;
        customer: record Customer;
        fbmcust: record FBM_Customer;
        site_old: record "Customer-Site";
        cos: record "Cust-Op-Site";
        cos_new: record FBM_CustOpSite;


    procedure dataMigration()
    begin
        if comp.FindFirst() then
            repeat
                Termsconditions_old.ChangeCompany(comp.Name);
                Termsconditions_new.ChangeCompany(comp.Name);

                if Termsconditions_old.FindFirst() then
                    repeat
                        Termsconditions_new.Init();
                        Termsconditions_new.Country := Termsconditions_old.Country;
                        Termsconditions_new."Line No." := Termsconditions_old."Line No.";
                        Termsconditions_new."Terms Conditions" := Termsconditions_old."Terms Conditions";
                        Termsconditions_new.Insert();
                    until Termsconditions_old.Next() = 0;
                customer.ChangeCompany(comp.Name);
                if customer.FindFirst() then
                    repeat
                        if not fbmcust.get(customer."No. 2") then begin
                            fbmcust.init;
                            fbmcust.TransferFields(customer, false);
                            fbmcust.Rename(customer."No. 2");
                            fbmcust.Modify();

                        end;
                    until customer.Next() = 0;
                cos.ChangeCompany(comp.Name);
                if cos.FindFirst() then
                    repeat
                        cos_new.Init();
                        cos_new."Customer No." := cos."Customer No.";
                        if customer.get(cos."Customer No.") then
                            cos_new."Operator No." := customer."No. 2";

                        cos_new."Site Code" := cos."Site Code 2";
                        cos_new.Insert();
                    until cos.Next() = 0;

            until comp.Next() = 0;
    end;
}