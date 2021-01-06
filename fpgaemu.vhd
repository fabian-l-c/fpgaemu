-- fpgaemu.vhd -  GHDL - C interface definitions
-- Author: Fabian L. Cabrera

package fpgaemu is

  type vin_type is
    array(integer range 0 to 1) of integer;
  type vin_p is access vin_type;

  function get_cinmem(f : integer) return vin_p;
    attribute foreign of get_cinmem :
      function is "VHPIDIRECT get_cmem";

  shared variable vhdlin : vin_p := get_cinmem(0);

  type vout_type is
    array(integer range 0 to 3) of integer;
  type vout_p is access vout_type;

  function get_coutmem(f : integer) return vout_p;
    attribute foreign of get_coutmem :
      function is "VHPIDIRECT get_cmem";

  shared variable vhdlout : vout_p := get_coutmem(1);

  type vck_type is
    array(integer range 0 to 1) of integer;
  type vck_p is access vck_type;

  function get_ckmem(f : integer) return vck_p;
    attribute foreign of get_ckmem :
      function is "VHPIDIRECT get_cmem";

  shared variable vhdlck : vck_p := get_ckmem(2);

end fpgaemu;

package body fpgaemu is

  function get_cinmem(f : integer) return vin_p is
  begin
    assert false report "VHPI" severity failure;
  end get_cinmem;

  function get_coutmem(f : integer) return vout_p is
  begin
    assert false report "VHPI" severity failure;
  end get_coutmem;

  function get_ckmem(f : integer) return vck_p is
  begin
    assert false report "VHPI" severity failure;
  end get_ckmem;

end fpgaemu;
