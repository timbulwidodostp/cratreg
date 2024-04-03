*! v1.2.0, S Bauldry, 18sep2017

capture program drop cr_pc_lf
program cr_pc_lf
  version 14

  * creating arguments based on number of categories of Y stored in globals
  local arguments "lnf xb_c xb_p"
	
  forval i = 2/$nCatm1 {
    local arguments "`arguments' f`i'"
  }
	
  args `arguments'
	
  forval i = 2/$nCatm1 {
    tempvar phi`i'
	qui gen double `phi`i'' = `f`i''
  }
  
  * setting values for y
  forval j = 1/$nCat {
    local y_`j' ${y_`j'}
  }
  local M $nCat
	
  *** likelihood function for logit link
  if ( "$Link" == "logit" ) {	

    * equation for first value of Y
    qui replace `lnf' = ln(invlogit(-`xb_c' - `xb_p')) if $ML_y == `y_1'
	
	* build equations for middle values of Y
	if ( $nCat == 3 ) {
	  qui replace `lnf' = ln(1 - invlogit(-`xb_c' - `xb_p')) +  ///
		                  ln(invlogit(-`xb_c' - `xb_p'*`phi2')) if $ML_y == `y_2'
	}
	
	if ( $nCat > 3 ) {
	  forval k = 2/$nCatm1 {
	    local meqn_a `" ln(1 - invlogit(-`xb_c' - `xb_p')) + "'
        local meqn_c `" ln(invlogit(-`xb_c' - `xb_p'*`phi`k'')) "'
    
	    local meqn_b ""
	    local m = `k' - 1
        forval n = 2/`m' {
          local meqn_b `" `meqn_b' ln(1 - invlogit(-`xb_c' - `xb_p'*`phi`n'')) + "'
        }
	
        local meqn `" `meqn_a' `meqn_b' `meqn_c' "'
        qui replace `lnf' = `meqn' if $ML_y == `y_`k''
      }
	}
	
	* build equation for last value of Y
    local eqn `" ln(1 - invlogit(-`xb_c' - `xb_p')) "'
	forval o = 2/$nCatm1 {
	  local eqn `" `eqn' + ln(1 - invlogit(-`xb_c' - `xb_p'*`phi`o'')) "'
    }
	qui replace `lnf' = `eqn' if $ML_y == `y_`M''
  }
  
  
  *** likelihood function for probit link
  if ( "$Link" == "probit" ) {	

    * equation for first value of Y
    qui replace `lnf' = ln(normal(-`xb_c' - `xb_p')) if $ML_y == `y_1'
	
	* build equations for middle values of Y
	if ( $nCat == 3 ) {
	  qui replace `lnf' = ln(1 - normal(-`xb_c' - `xb_p')) +  ///
		                  ln(normal(-`xb_c' - `xb_p'*`phi2')) if $ML_y == `y_2'
	}
	
	if ( $nCat > 3 ) {
	  forval k = 2/$nCatm1 {
	    local meqn_a `" ln(1 - normal(-`xb_c' - `xb_p')) + "'
        local meqn_c `" ln(normal(-`xb_c' - `xb_p'*`phi`k'')) "'
    
	    local meqn_b ""
	    local m = `k' - 1
        forval n = 2/`m' {
          local meqn_b `" `meqn_b' ln(1 - normal(-`xb_c' - `xb_p'*`phi`n'')) + "'
        }
	
        local meqn `" `meqn_a' `meqn_b' `meqn_c' "'
        qui replace `lnf' = `meqn' if $ML_y == `y_`k''
      }
	}
	
	* build equation for last value of Y
    local eqn `" ln(1 - normal(-`xb_c' - `xb_p')) "'
	forval o = 2/$nCatm1 {
	  local eqn `" `eqn' + ln(1 - normal(-`xb_c' - `xb_p'*`phi`o'')) "'
    }
	qui replace `lnf' = `eqn' if $ML_y == `y_`M''
  }
  
  
    *** likelihood function for complementary log-log link
  if ( "$Link" == "cloglog" ) {	

    * equation for first value of Y
    qui replace `lnf' = ln(1 - exp(-exp(-`xb_c' - `xb_p'))) if $ML_y == `y_1'
	
	* build equations for middle values of Y
	if ( $nCat == 3 ) {
	  qui replace `lnf' = ln(exp(-exp(-`xb_c' - `xb_p'))) +  ///
		                  ln(1 - exp(-exp(-`xb_c' - `xb_p'*`phi2'))) if $ML_y == `y_2'
	}
	
	if ( $nCat > 3 ) {
	  forval k = 2/$nCatm1 {
	    local meqn_a `" ln(exp(-exp(-`xb_c' - `xb_p'))) + "'
        local meqn_c `" ln(1 - exp(-exp(-`xb_c' - `xb_p'*`phi`k''))) "'
    
	    local meqn_b ""
	    local m = `k' - 1
        forval n = 2/`m' {
          local meqn_b `" `meqn_b' ln(exp(-exp(-`xb_c' - `xb_p'*`phi`n''))) + "'
        }
	
        local meqn `" `meqn_a' `meqn_b' `meqn_c' "'
        qui replace `lnf' = `meqn' if $ML_y == `y_`k''
      }
	}
	
	* build equation for last value of Y
    local eqn `" ln(exp(-exp(-`xb_c' - `xb_p'))) "'
	forval o = 2/$nCatm1 {
	  local eqn `" `eqn' + ln(exp(-exp(-`xb_c' - `xb_p'*`phi`o''))) "'
    }
	qui replace `lnf' = `eqn' if $ML_y == `y_`M''
  }

end


/* History
1.0.0  11.22.16  initial likelihood program for arbitrary number of categories
1.1.0  08.25.17  generalized program for unlimited number of categories
1.2.0  09.18.17  fixed bug with non-standard values for Y
