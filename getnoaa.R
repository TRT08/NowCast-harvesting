#Nowcast2d
#http://data.glos.us/glcfs/glcfsps.glos?lake=michigan&i=-86.5283&j=45.251&v=depth,eta,uc,vc,utm,vtm,wvh,wvd,wvp,ci,hi&st=2014-12-01:00:00:00&et=2014-12-16:00:00:00&order=asc&pv=1&doy=1&tzf=-5&f=csv
Nowcast2d <- function(lake, Longitude, Latitude, params, startdate, enddate)
  {
  base_url <- 'http://data.glos.us/glcfs/glcfsps.glos?' 
  
# compose final url
final_url <- paste(base_url,
'lake=', lake,
'&i=', Longitude,
'&j=', Latitude, 
'&v=', params,
'&st=', startdate,':00:00:00',
'&et=', enddate,':00:00:00',
'&order=asc&pv=1&doy=1&tzf=-5&f=csv', sep='')

  # reading in as raw lines from the web server
  # contains <br> tags on every other line
  u <- url(final_url)
  the_data <- readLines(u)
  close(u)
  
  # only keep records with more than 5 rows of data
  if(length(the_data) > 5 )
        {

      # remove the leading lines
        the_data <- the_data[-c(1:4)]
        
       # extract header and cleanup
        the_header <- the_data[1]
        the_header <- make.names(strsplit(the_header, ',')[[1]])
        
        # convert to CSV, without header
        tC <- textConnection(paste(the_data, collapse='\n'))
        the_data <- read.csv(tC, as.is=TRUE, row.names=NULL, header=FALSE, skip=1)
        close(tC)
        
        # remove the last column, created by trailing comma
        the_data <- the_data[, -ncol(the_data)]
        
        # assign column names
        names(the_data) <- the_header
        
       the_data$Lat <- Latitude
       the_data$Long <- Longitude
       
        # done
        return(the_data)
        }
  }


#Nowcast Input
#http://data.glos.us/glcfs/glcfsps.glos?lake=michigan&i=-86.5283&j=45.251&v=depth,air_u,air_v,cl,at,dp&in=1&st=2014-12-01:00:00:00&et=2014-12-16:00:00:00&order=asc&pv=1&doy=1&tzf=-5&f=csv

NowcastInput <- function(lake, Longitude, Latitude, params, startdate, enddate)
{
  base_url <- 'http://data.glos.us/glcfs/glcfsps.glos?' 
  
  # compose final url
  final_url <- paste(base_url,
                     'lake=', lake,
                     '&i=', Longitude,
                     '&j=', Latitude, 
                     '&v=', params,
                     '&in=1&st=', startdate,':00:00:00',
                     '&et=', enddate,':00:00:00',
                     '&order=asc&pv=1&doy=1&tzf=-5&f=csv', sep='')
  
  # reading in as raw lines from the web server
  # contains <br> tags on every other line
  u <- url(final_url)
  the_data <- readLines(u)
  close(u)
  
  # only keep records with more than 5 rows of data
  if(length(the_data) > 5 )
  {
    
    # remove the leading lines
    the_data <- the_data[-c(1:4)]
    
    # extract header and cleanup
    the_header <- the_data[1]
    the_header <- make.names(strsplit(the_header, ',')[[1]])
    
    # convert to CSV, without header
    tC <- textConnection(paste(the_data, collapse='\n'))
    the_data <- read.csv(tC, as.is=TRUE, row.names=NULL, header=FALSE, skip=1)
    close(tC)
    
    # remove the last column, created by trailing comma
    the_data <- the_data[, -ncol(the_data)]
    
    # assign column names
    names(the_data) <- the_header
    
    the_data$Lat <- Latitude
    the_data$Long <- Longitude
    
    # done
    return(the_data)
  }
}


