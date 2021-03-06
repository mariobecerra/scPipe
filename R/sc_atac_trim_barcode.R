#' sc_atac_trim_barcode()
#'
#' @return 
#'
#' @examples
#' \dontrun{
#' 
#' 
#' }
#'
#' @export
#'
sc_atac_trim_barcode = function(
  r1, 
  r2, 
  bc_file, 
  output_folder = "", 
  bc_start=-1, 
  bc_length=-1, 
  umi_start=0, 
  umi_length=0, 
  umi_in = "both", 
  rmN = FALSE,
  rmlow = FALSE,
  min_qual = 20,
  num_below_min = 2,
  id1_st = -1,
  id1_len = -1,
  id2_st = -1,
  id2_len = -10) {
  
  if(output_folder == ''){
    output_folder = file.path(getwd(), "scPipe-atac-output")
  }
  if (!dir.exists(output_folder)){
    dir.create(output_folder,recursive=TRUE)
    cat("Output Directory Does Not Exist. Created Directory: ", output_folder, "\n")
  }
  
  if (substr(r1, nchar(r1) - 2, nchar(r1)) == ".gz") {
    write_gz = TRUE
  }
  else {
    write_gz = FALSE
  }
  
  if (!is.null(bc_file)) {
    if (!file.exists(r1)) {stop("read1 fastq file does not exist.")}
    i=1;
    for (bc in bc_file) {
      if (!file.exists(bc)) {stop("Barcode file does not exist.")}
      bc_file[i] = path.expand(bc)
      i = i+1;
    }
    
    if(umi_start != 0){
      if(umi_in %in% c("both", "R1", "R2")){
        cat("UMI Present in: ", umi_in, "\n")
      }else{
        stop("Invalid value of umi_in. Possible values are both, R1 and R2")
      }
    }
    
    # expand tilde to home path for downstream gzopen() call
    r1 = path.expand(r1)
    
    if(!is.null(r2)){
      if (!file.exists(r2)) {stop("read2 file does not exist.")}
      r2 = path.expand(r2)
    }else{
      r2=""
    }
    cat("Saving the output at location: ")
    cat(output_folder)
    cat("\n")
    
    if(file_ext(bc_file) != 'csv'){
      rcpp_sc_atac_trim_barcode_paired(
        output_folder, 
        r1, 
        bc_file,
        r2,write_gz,
        rmN,
        rmlow,
        min_qual,
        num_below_min,
        id1_st,
        id1_len,
        id2_st,
        id2_len,
        umi_start, 
        umi_length)
    }
    else {
      cat("Using barcode CSV file, since Barcode FastQ file not passed \n ")
      if(bc_start == -1 || bc_length == -1 ){
        stop("Please pass bc_start and bc_length values")
      }
      rcpp_sc_atac_trim_barcode(
        output_folder, 
        r1, 
        r2, 
        bc_file, 
        bc_start, 
        bc_length, 
        umi_start, 
        umi_length, 
        umi_in, 
        write_gz,
        rmN,
        rmlow,
        min_qual,
        num_below_min,
        id1_st,
        id1_len,
        id2_st,
        id2_len)
    }
  }else{
    stop("Barcode file is mandatory")
  }
}



