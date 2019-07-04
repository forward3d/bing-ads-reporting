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
            <ReportDownloadUrl>
              https://dvsrdl.api.bingads.microsoft.com/ReportDownload/Download.aspx?q=FBqXVvpqWWQ26Tg3Qk2Kj%2fuF%2fl%2f1TpU3%2f9yGytBUbumcfnHv6tJ%2fcrS5QmcZBcCofYr5SHnz547sx8oc7GcT3pLQ%2fV7wVOy74goZiTpEBszi924kJTtnhDhQHFfcoQTdscNpCq7H%2frM842mw9HyxntlNWNi1o5aWENXh1jHk55LWz3l7D7Foe82izhbtNHf%2f%2buGXBqN2%2bLjhsN6b3Wyybfz6oQaZ%2b2Mm27NH2rMPbwUslFIJvpfDzEnG3CLtEJ2Bb1scQ8vCRtvJPOhcS3ZrTHs39lIM0YAP78J%2bkGu2Xji9HhAHb7yK%2fDJh7o64rPa%2f1PwbZdxPUXUU4FkVFLSyM07nQ9F3osQ2cxvdO%2fAfm4HI0hi5K2JfxiiBCvyN2R0%2b7VQ6vUQw%2b0HWmdMar6Z8k1quZjfWR%2fU9CeCNkkx%2bL2uwtkMhIEomTiXdoLB5o5dAQSM7rOsnZ5jh%2f2AC1AMO%2bWRRLfAAN2lEN8o6cYWEF4duDg2BgRHuV6xSorFcxExUUxRty%2b0pNb2cL%2bdXPuK5tbaDfVls0iKbbMhZs%2fSBYMOVOyfXBbGDyXDIb5o709iPgTjgGHKn4Gnqqf0LTvC1SBcwuZVdbaLt9MXZ5XsktoQ76kIWF%2bmAuFw2tWbR4yScxgWvVqLsDiH%2fIalb95QGErZxypT9xPumGRgNaQ6wzaNrmXcgZWZjr%2fW1wbwGy0WvP%2bkyWOHIBnFiktnt2zhCYaEb7VCfs0n8wQFCwM%2bvDaiUSk7rO%2foHP%2f%2b1lx0H7R76gtNde4BhBlpIeDsO%2bUwizcDPSWUF3rqj2TwygYjNAWH8
            </ReportDownloadUrl>
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
end
