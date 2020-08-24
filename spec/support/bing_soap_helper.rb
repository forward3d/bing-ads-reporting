module BingSoapHelper
  def self.poll_report_error
    '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
      <s:Header>
        <h:TrackingId xmlns:h="https://bingads.microsoft.com/Reporting/v12">
          1a3e2bcc-6b29-4253-90b6-5ddadf993947
        </h:TrackingId>
      </s:Header>
      <s:Body>
        <PollGenerateReportResponse xmlns="https://bingads.microsoft.com/Reporting/v12">
          <ReportRequestStatus xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <Status>Error</Status>
          </ReportRequestStatus>
        </PollGenerateReportResponse>
      </s:Body>
    </s:Envelope>'
  end

  def self.poll_report_ready
    '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
      <s:Header>
        <h:TrackingId xmlns:h="https://bingads.microsoft.com/Reporting/v12">
          1a3e2bcc-6b29-4253-90b6-5ddadf993947
        </h:TrackingId>
      </s:Header>
      <s:Body>
        <PollGenerateReportResponse xmlns="https://bingads.microsoft.com/Reporting/v12">
          <ReportRequestStatus xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <ReportDownloadUrl>https://api.bingads.microsoft.com/ReportDownload/Download.aspx?q=FBqXV8</ReportDownloadUrl>
            <Status>Success</Status>
          </ReportRequestStatus>
        </PollGenerateReportResponse>
      </s:Body>
    </s:Envelope>'
  end

  def self.poll_report_without_url
    '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
      <s:Header>
        <h:TrackingId xmlns:h="https://bingads.microsoft.com/Reporting/v12">
          1a3e2bcc-6b29-4253-90b6-5ddadf993947
        </h:TrackingId>
      </s:Header>
      <s:Body>
        <PollGenerateReportResponse xmlns="https://bingads.microsoft.com/Reporting/v12">
          <ReportRequestStatus xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <Status>Success</Status>
          </ReportRequestStatus>
        </PollGenerateReportResponse>
      </s:Body>
    </s:Envelope>'
  end

  def self.poll_report_not_ready
    '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
      <s:Header>
        <h:TrackingId xmlns:h="https://bingads.microsoft.com/Reporting/v12">
          1a3e2bcc-6b29-4253-90b6-5ddadf993947
        </h:TrackingId>
      </s:Header>
      <s:Body>
        <PollGenerateReportResponse xmlns="https://bingads.microsoft.com/Reporting/v12">
          <ReportRequestStatus xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
            <Status>Waiting</Status>
          </ReportRequestStatus>
        </PollGenerateReportResponse>
      </s:Body>
    </s:Envelope>'
  end

  def self.bulk_service_report_submit
    '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
      <s:Header>
        <h:TrackingId xmlns:h="https://bingads.microsoft.com/CampaignManagement/v12">
          9e62cca1-78e7-429a-bb0a-58bac22d2c90
        </h:TrackingId>
      </s:Header>
      <s:Body>
        <GetBulkDownloadStatusResponse xmlns="https://bingads.microsoft.com/CampaignManagement/v12">
          <DownloadRequestId>68818318726</DownloadRequestId>
        </GetBulkDownloadStatusResponse>
      </s:Body>
    </s:Envelope>'
  end

  def self.poll_bulk_service_error
    '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
      <s:Header>
        <h:TrackingId xmlns:h="https://bingads.microsoft.com/CampaignManagement/v12">
          9e62cca1-78e7-429a-bb0a-58bac22d2c90
        </h:TrackingId>
      </s:Header>
      <s:Body>
        <GetBulkDownloadStatusResponse xmlns="https://bingads.microsoft.com/CampaignManagement/v12">
          <RequestStatus>Failed</RequestStatus>
          <Errors>
            <Error>Some Error</Error>
          </Errors>
        </GetBulkDownloadStatusResponse>
      </s:Body>
    </s:Envelope>'
  end

  def self.poll_bulk_service_not_complete
    '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
      <s:Header>
        <h:TrackingId xmlns:h="https://bingads.microsoft.com/CampaignManagement/v12">
          9e62cca1-78e7-429a-bb0a-58bac22d2c90
        </h:TrackingId>
      </s:Header>
      <s:Body>
        <GetBulkDownloadStatusResponse xmlns="https://bingads.microsoft.com/CampaignManagement/v12">
          <PercentComplete>10</PercentComplete>
          <RequestStatus>InProgress</RequestStatus>
        </GetBulkDownloadStatusResponse>
      </s:Body>
    </s:Envelope>'
  end

  def self.poll_bulk_service_completed
    '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
      <s:Header>
        <h:TrackingId xmlns:h="https://bingads.microsoft.com/CampaignManagement/v12">
          9e62cca1-78e7-429a-bb0a-58bac22d2c90
        </h:TrackingId>
      </s:Header>
      <s:Body>
        <GetBulkDownloadStatusResponse xmlns="https://bingads.microsoft.com/CampaignManagement/v12">
          <PercentComplete>100</PercentComplete>
          <RequestStatus>Completed</RequestStatus>
          <ResultFileUrl>https://bingadsappsstorageprod.blob.core.windows.net/bulkdownloadresultfiles/bulkfile.tsv</ResultFileUrl>
        </GetBulkDownloadStatusResponse>
      </s:Body>
    </s:Envelope>'
  end
end
