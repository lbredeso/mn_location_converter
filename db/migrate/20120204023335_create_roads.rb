class CreateRoads < ActiveRecord::Migration
  def up
    execute %{
      CREATE TABLE "roads" (gid serial PRIMARY KEY,
        "str_name" varchar(42),
        "str_pfx" varchar(2),
        "base_nam" varchar(50),
        "str_type" varchar(4),
        "str_sfx" varchar(2),
        "e_911" varchar(1),
        "tis_code" varchar(11),
        "rte_syst" varchar(2),
        "rte_num" varchar(5),
        "divid" varchar(1),
        "traf_dir" varchar(1),
        "tis_one" varchar(16),
        "status" varchar(1),
        "date_pro" date,
        "date_act" date,
        "date_ret" date,
        "date_edt" date,
        "shape_leng" numeric,
        "begm" float8,
        "endm" float8,
        "cnty_code" varchar(254),
        "directiona" varchar(254)
      );
    }
  end

  def down
    drop_table :roads
  end
end
