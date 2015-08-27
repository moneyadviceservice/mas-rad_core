module QueueSpecHelper
  def clear_job_queue
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  def queue_contains_a_job_for(job_class)
    ActiveJob::Base.queue_adapter.enqueued_jobs.any? do |elem|
      elem[:job] == job_class
    end
  end
end
