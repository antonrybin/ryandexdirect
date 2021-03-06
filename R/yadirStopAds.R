yadirStopAds <-  function(Login = NULL, 
                          Ids   = NULL,
                          Token = NULL,
                          AgencyAccount = NULL,
                          TokenPath     = getwd()){
  
  #�������� ���������� ������
  #�����������
  Token <- tech_auth(login = Login, token = Token, AgencyAccount = AgencyAccount, TokenPath = TokenPath)
  
  if(length(Ids) > 10000){
    stop(paste0("� �������� Ids �������� ������ ",length(Ids), " ����������, ����������� ���������� ���������� ���������� � ����� ������� 10000."))
  }
  
  if(is.null(Ids)){
    stop("� �������� Ids ���������� �������� ������ ���������� Id ���������� �� ������� ���������� ���������� �����. �� �� �������� �������� Id.")
  }
  
  #������� ������
  CounErr <- 0
  
  #Error vector
  errors_id <-  vector()
  
  #��������� ����� ������ ������
  start_time  <- Sys.time()
  
  #����� ��������� offset
  lim <- 0
  
  #��������� � ������ ��������� ������
  packageStartupMessage("Processing", appendLF = T)
  
  IdsPast <- paste0(Ids, collapse = ",")
  #��������� ���� POST �������
  queryBody <- paste0("{
                      \"method\": \"suspend\",
                      \"params\": { 
                      \"SelectionCriteria\": {
                      \"Ids\": [",IdsPast,"]}
}
}")
  
  #�������� �������
  answer <- POST("https://api.direct.yandex.com/json/v5/ads", body = queryBody, add_headers(Authorization = paste0("Bearer ",Token), 'Accept-Language' = "ru","Client-Login" = Login))
  #������ �����
  ans_pars <- content(answer)
  #�������� ������ �� ������� ������
  if(!is.null(ans_pars$error)){
    stop(paste0("������: ", ans_pars$error$error_string,". ���������: ",ans_pars$error$error_detail, ". ID �������: ",ans_pars$error$request_id))
  }
  
  #�������� �������������� ��������
  for(error_search in 1:length(ans_pars$result$SuspendResults)){
    if(!is.null(ans_pars$result$SuspendResults[[error_search]]$Errors)){
      CounErr <- CounErr + 1
      errors_id <- c(errors_id, Ids[error_search])
      packageStartupMessage(paste0("    AdId: ",Ids[error_search]," - ", ans_pars$result$SuspendResults[[error_search]]$Errors[[1]]$Details))
    }
  }
  
  #���������� ��������� ��� ���������� ������������� ��������
  out_message <- ""
  
  TotalCampStoped <- length(Ids) - CounErr
  
  if(TotalCampStoped %in% c(2,3,4) & !(TotalCampStoped %% 100 %in% c(12,13,14))){
    out_message <- "���������� �����������"
  } else if(TotalCampStoped %% 10 == 1 & TotalCampStoped %% 100 != 11){
    out_message <- "���������� �����������"
  } else {
    out_message <- "���������� ����������"
  }
  
  #������� ����������
  packageStartupMessage(paste0(TotalCampStoped, " ", out_message))
  packageStartupMessage(paste0("����� ����� ������ �������: ", as.integer(round(difftime(Sys.time(), start_time , units ="secs"),0)), " ���."))
  return(errors_id)}