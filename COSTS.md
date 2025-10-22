# Cost Estimation Guide

This document provides cost estimates for running LLM inference on GKE with GPU nodes.

## 💰 Monthly Cost Breakdown

### Default Configuration (us-central1)

| Component | Specification | Monthly Cost (USD) |
|-----------|--------------|-------------------|
| **GKE Cluster** | Management fee | $74.40 |
| **CPU Nodes** | 2x n1-standard-4 (24/7) | ~$292.00 |
| **GPU Nodes** | 1x n1-standard-8 + T4 GPU (24/7) | ~$588.00 |
| **Cloud NAT** | NAT gateway (24/7) | ~$45.00 |
| **Networking** | Load Balancer + egress | ~$40.00 |
| **Storage** | 200GB SSD + misc | ~$40.00 |
| **TOTAL (24/7 operation)** | | **~$1,079.40/month** |

### Cost-Optimized Configuration

| Component | Specification | Monthly Cost (USD) |
|-----------|--------------|-------------------|
| **GKE Cluster** | Management fee | $74.40 |
| **CPU Nodes** | 1x n1-standard-2 (24/7) | ~$73.00 |
| **GPU Nodes** | 1x Spot n1-standard-8 + T4 (12h/day) | ~$147.00 |
| **Cloud NAT** | NAT gateway (24/7) | ~$45.00 |
| **Networking** | Load Balancer + egress | ~$40.00 |
| **Storage** | 100GB Standard + misc | ~$10.00 |
| **TOTAL (12h/day operation)** | | **~$389.40/month** |

## 📊 GPU Pricing Comparison (us-central1)

### On-Demand Pricing

| GPU Type | GPU Cost/hour | Machine Cost/hour | Total/hour | Total/month (24/7) |
|----------|---------------|-------------------|------------|-------------------|
| T4 | $0.35 | $0.38 | $0.73 | $547.50 |
| V100 | $2.48 | $0.52 | $3.00 | $2,190.00 |
| A100 (40GB) | $2.93 | $0.87 | $3.80 | $2,774.00 |
| L4 | $0.79 | $0.52 | $1.31 | $956.30 |

### Spot/Preemptible Pricing (60-91% discount)

| GPU Type | GPU Cost/hour | Machine Cost/hour | Total/hour | Total/month (24/7) |
|----------|---------------|-------------------|------------|-------------------|
| T4 | $0.105 | $0.114 | $0.22 | $164.25 |
| V100 | $0.74 | $0.156 | $0.90 | $657.00 |
| A100 (40GB) | $0.88 | $0.261 | $1.14 | $831.60 |
| L4 | $0.24 | $0.156 | $0.40 | $288.90 |

*Note: Spot instances can be preempted but offer significant cost savings*

## 🎯 Cost Optimization Strategies

### 1. Use Spot/Preemptible Instances (Save 60-70%)

**Terraform Configuration:**
```hcl
# Add to main.tf GPU node pool
spot = true
```

**Savings:** ~$383/month on T4 GPU
**Trade-off:** Instances can be preempted, need to handle interruptions

### 2. Scale to Zero During Off-Hours (Save 50%+)

**Example: Run only during business hours (12h/day)**
```bash
# Scale down at night
gcloud container clusters resize llm-deployment-gke-cluster \
  --node-pool gpu-pool --num-nodes 0 --region us-central1

# Scale up in morning
gcloud container clusters resize llm-deployment-gke-cluster \
  --node-pool gpu-pool --num-nodes 1 --region us-central1
```

**Savings:** ~$274/month (50% of GPU+node costs)
**Automation:** Use Cloud Scheduler or Kubernetes CronJobs

### 3. Use Smaller Models (Save on GPU requirements)

| Model Size | Required GPU | Monthly Cost | Inference Speed |
|------------|--------------|--------------|----------------|
| 2B params (Phi-2) | T4 (16GB) | ~$547 | Very Fast |
| 7B params (Mistral) | T4 (16GB) | ~$547 | Fast |
| 13B params (Llama-2) | L4 (24GB) or 2xT4 | ~$956 | Medium |
| 70B params (Llama-2) | 4xA100 | ~$11,096 | Slower |

**Recommendation:** Start with 7B models (Mistral, Llama-2-7B) on T4

### 4. Enable Cluster Autoscaler

**Already configured in Terraform:**
- `gpu_min_nodes = 0` - Scale to zero when no load
- `gpu_max_nodes = 3` - Scale up under load

**Savings:** Pay only for what you use
**Best for:** Variable/unpredictable workloads

### 5. Use Quantization (Reduce GPU memory requirements)

**4-bit quantization** can reduce memory by 75%:
- 7B model: 14GB → 3.5GB (can use smaller/cheaper GPU)
- 13B model: 26GB → 6.5GB (fits on T4 instead of L4)

**Implementation:**
```yaml
env:
- name: QUANTIZATION
  value: "bitsandbytes"  # or "awq", "gptq"
```

### 6. Regional Pricing Differences

| Region | T4 GPU/hour | Difference from us-central1 |
|--------|-------------|---------------------------|
| us-central1 (Iowa) | $0.35 | Baseline |
| us-west1 (Oregon) | $0.35 | Same |
| us-east1 (S. Carolina) | $0.35 | Same |
| europe-west4 (Netherlands) | $0.385 | +10% |
| asia-southeast1 (Singapore) | $0.455 | +30% |

**Recommendation:** Use US regions for lowest cost

### 7. Committed Use Discounts (Save 37-70%)

**1-year commitment:**
- T4: 37% discount
- V100: 37% discount

**3-year commitment:**
- T4: 55% discount
- V100: 55% discount

**Example Savings (T4 GPU):**
- On-demand: $547/month
- 1-year commit: $345/month (save $202/month)
- 3-year commit: $246/month (save $301/month)

**Apply at:** GCP Console → Compute Engine → Committed use discounts

## 📈 Usage Patterns and Costs

### Development/Testing
- **Pattern:** 8 hours/day, weekdays only
- **GPU Time:** ~160 hours/month
- **Cost:** ~$117/month (T4 on-demand)
- **Recommended:** Spot instances, scale to zero

### Production (Low Traffic)
- **Pattern:** 24/7, low utilization
- **GPU Time:** 730 hours/month
- **Cost:** ~$547/month (T4 on-demand)
- **Recommended:** 1x T4, enable autoscaling, use committed discount

### Production (High Traffic)
- **Pattern:** 24/7, high utilization
- **GPU Time:** 2,190 hours/month (3 GPUs)
- **Cost:** ~$1,641/month (3x T4 on-demand)
- **Recommended:** 3x T4, committed use discount, consider Reserved instances

### Enterprise/High-Performance
- **Pattern:** 24/7, maximum performance
- **GPU Time:** 730 hours/month (A100)
- **Cost:** ~$2,774/month (A100 on-demand)
- **Recommended:** A100 or L4, committed discount, optimize model loading

## 🧮 Cost Calculator

### Your Configuration
```
Monthly Cost = 
  GKE Management ($74.40) +
  CPU Nodes (node_count × machine_cost × 730h × spot_discount) +
  GPU Nodes (node_count × (machine_cost + gpu_cost) × 730h × spot_discount × usage_factor) +
  Networking (~$40) +
  Storage (GB × $0.17)
```

### Example Calculation
```
Configuration:
- 1x n1-standard-4 CPU node (24/7)
- 1x n1-standard-8 + T4 GPU (12h/day, spot)
- 100GB storage

Cost:
  $74.40 (GKE) +
  $146 (CPU: $0.20/h × 730h) +
  $80 (GPU+node spot: $0.22/h × 365h) +
  $40 (networking) +
  $17 (storage: 100GB × $0.17)
= $357.40/month
```

## 🎁 Free Tier & Credits

### Google Cloud Free Trial
- **$300 credit** for 90 days
- Can run full setup for ~3 months free
- Limitations: Some regions, quotas apply

### Startup Programs
- **Google for Startups:** Up to $200k in credits
- **Education:** $300 per student
- **Research:** Custom grants available

## 📊 Monitoring Costs

### Enable Cost Tracking
```bash
# View current costs
gcloud billing accounts list
gcloud billing projects link YOUR_PROJECT_ID --billing-account=YOUR_BILLING_ACCOUNT

# Set up budgets and alerts
```

### Cost Optimization Tools
1. **Cost Analysis Dashboard**: Console → Billing → Cost breakdown
2. **Budgets & Alerts**: Set spending limits
3. **Recommendations**: Automated optimization suggestions
4. **Committed Use**: Purchase commitments for discounts

## 🚨 Cost Warnings

### High-Cost Mistakes to Avoid

1. **Forgetting to scale down** 
   - Cost: $547/month per idle GPU
   - Solution: Set `gpu_min_nodes = 0`

2. **Using wrong GPU type**
   - Cost: A100 vs T4 = 5x more expensive
   - Solution: Match GPU to workload

3. **Not using spot instances**
   - Cost: 3x more than spot pricing
   - Solution: Enable spot for non-critical workloads

4. **Large egress traffic**
   - Cost: $0.12/GB for internet egress
   - Solution: Use CDN, optimize data transfer

5. **Persistent disks not cleaned up**
   - Cost: $0.17/GB/month accumulates
   - Solution: Regular cleanup, use lifecycle policies

## 📞 Cost Support

- **Cost Optimization Support**: Cloud Billing Support
- **Technical Support**: Based on support tier
- **Community**: GCP Slack, Stack Overflow

---

*Last Updated: October 2025*
*Prices are subject to change. Check [GCP Pricing Calculator](https://cloud.google.com/products/calculator) for current rates.*

