#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
generate_visualizations.py - Generate visualizations for open source contribution patterns

This script creates various visualizations based on the metadata.json file, including:
- Contribution heatmap by year and domain
- PR timeline showing contribution frequency
- Domain distribution pie chart
- Language usage bar chart
- Project scale breakdown
- Repository stars impact chart

Usage:
  python3 generate_visualizations.py [--output-dir OUTPUT_DIR]

Arguments:
  --output-dir       Directory to save visualization images (default: ../visualizations)

Requirements:
  matplotlib, numpy, pandas, seaborn

Author: xz-dev
Created: 2026-02-04
License: MIT
"""

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path

try:
    import matplotlib.pyplot as plt
    import matplotlib.dates as mdates
    import numpy as np
    import pandas as pd
    import seaborn as sns
except ImportError:
    print("Error: Required libraries not installed.")
    print("Please install required libraries with:")
    print("pip install matplotlib numpy pandas seaborn")
    sys.exit(1)

# Set styles for consistent visualizations
plt.style.use("seaborn-v0_8-darkgrid")
plt.rcParams["font.sans-serif"] = [
    "SimHei",
    "DejaVu Sans",
    "Arial",
]  # For Chinese character support
plt.rcParams["axes.unicode_minus"] = False  # Properly display negative signs
COLORS = sns.color_palette("muted")


def load_data(metadata_path):
    """Load and parse metadata.json file."""
    try:
        with open(metadata_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error loading metadata file: {e}")
        sys.exit(1)


def create_output_dir(output_dir):
    """Create output directory if it doesn't exist."""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Created output directory: {output_dir}")


def generate_contribution_heatmap(metadata, output_dir):
    """Generate a heatmap of contributions by year and domain."""
    print("Generating contribution heatmap...")

    # Extract year and domain statistics
    years = list(metadata["statistics"]["by_year"].keys())
    domains = list(metadata["statistics"]["by_domain"].keys())

    # Prepare dummy data (in a real implementation, you'd extract this from the PR data)
    # This would require having PR counts per year per domain in metadata

    # For now we'll generate some synthetic data based on total counts
    data = np.zeros((len(domains), len(years)))
    year_totals = list(metadata["statistics"]["by_year"].values())
    domain_totals = list(metadata["statistics"]["by_domain"].values())

    # Distribute domain totals across years proportionally
    for i, domain_total in enumerate(domain_totals):
        for j, year_total in enumerate(year_totals):
            # Simple distribution formula - this is just a placeholder
            # In reality, you'd use actual counts per domain per year
            data[i, j] = (domain_total * year_total) / sum(year_totals)

        # Normalize to actual domain total
        if sum(data[i, :]) > 0:
            data[i, :] = data[i, :] * domain_total / sum(data[i, :])

    # Prepare domain labels with more user-friendly names
    domain_labels = [
        "Linux内核",
        "Windows驱动",
        "容器技术",
        "AI基础设施",
        "Android",
        "Gentoo生态",
    ]

    # Create heatmap
    plt.figure(figsize=(12, 8))
    ax = sns.heatmap(
        data,
        annot=True,
        fmt=".0f",
        cmap="YlGnBu",
        xticklabels=years,
        yticklabels=domain_labels,
        linewidths=0.5,
    )

    plt.title("贡献热图 (按年份和领域)", fontsize=16)
    plt.xlabel("年份", fontsize=12)
    plt.ylabel("技术领域", fontsize=12)

    # Rotate x-axis labels
    plt.xticks(rotation=45)

    # Tight layout
    plt.tight_layout()

    # Save figure
    plt.savefig(
        os.path.join(output_dir, "contribution_heatmap.png"),
        dpi=300,
        bbox_inches="tight",
    )
    plt.close()


def generate_contribution_timeline(metadata, output_dir):
    """Generate a timeline of contributions by year."""
    print("Generating contribution timeline...")

    years = list(metadata["statistics"]["by_year"].keys())
    counts = list(metadata["statistics"]["by_year"].values())

    # Convert to proper datetime objects for x-axis
    x = [datetime.strptime(year, "%Y") for year in years]

    plt.figure(figsize=(12, 6))

    # Create bar chart
    plt.bar(x, counts, width=250, color=COLORS[0], alpha=0.7)

    # Add trend line
    plt.plot(x, counts, "o-", color=COLORS[1], linewidth=2, markersize=8)

    # Format x-axis
    plt.gca().xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
    plt.gca().xaxis.set_major_locator(mdates.YearLocator())

    # Add labels and title
    plt.title("贡献时间线 (2017-2026)", fontsize=16)
    plt.xlabel("年份", fontsize=12)
    plt.ylabel("PR数量", fontsize=12)

    # Add data labels on bars
    for i, (year, count) in enumerate(zip(x, counts)):
        plt.text(year, count + 1, str(count), ha="center", fontweight="bold")

    # Add annotations for key events
    # These would need to be manually defined
    key_events = [
        {"year": "2019", "event": "UpgradeAll项目", "y_offset": 5},
        {"year": "2023", "event": "Gentoo维护者", "y_offset": 5},
        {"year": "2025", "event": "Klavis AI", "y_offset": 8},
    ]

    max_count = max(counts)

    for event in key_events:
        event_year = datetime.strptime(event["year"], "%Y")
        year_index = years.index(event["year"])
        count = counts[year_index]

        plt.annotate(
            event["event"],
            xy=(event_year, count),
            xytext=(event_year, count + max_count * (event["y_offset"] / 100)),
            arrowprops=dict(facecolor="black", shrink=0.05, width=1.5, headwidth=8),
            ha="center",
            fontsize=10,
        )

    # Grid and limits
    plt.grid(axis="y", linestyle="--", alpha=0.7)
    plt.ylim(0, max_count * 1.2)  # Add some headroom for annotations

    # Tight layout
    plt.tight_layout()

    # Save figure
    plt.savefig(
        os.path.join(output_dir, "contribution_timeline.png"),
        dpi=300,
        bbox_inches="tight",
    )
    plt.close()


def generate_domain_pie_chart(metadata, output_dir):
    """Generate a pie chart showing distribution of contributions by domain."""
    print("Generating domain distribution pie chart...")

    domains = list(metadata["statistics"]["by_domain"].keys())
    counts = list(metadata["statistics"]["by_domain"].values())

    # Map domain keys to human-readable labels
    domain_labels = {
        "linux-kernel": "Linux内核与驱动",
        "windows-drivers": "Windows驱动",
        "container-tech": "容器技术",
        "ai-infrastructure": "AI基础设施",
        "android": "Android开发",
        "gentoo-ecosystem": "Gentoo生态",
    }

    # Calculate percentages
    total = sum(counts)
    percentages = [count / total * 100 for count in counts]

    # Prepare labels with percentages
    labels = [
        f"{domain_labels.get(domain, domain)} ({percentage:.1f}%)"
        for domain, percentage in zip(domains, percentages)
    ]

    plt.figure(figsize=(10, 8))

    # Create pie chart with custom colors
    wedges, texts, autotexts = plt.pie(
        counts,
        labels=None,  # We'll add custom legend
        autopct="%1.1f%%",
        startangle=90,
        shadow=False,
        colors=COLORS,
        wedgeprops={"edgecolor": "w", "linewidth": 1, "antialiased": True},
    )

    # Customize text properties
    plt.setp(autotexts, size=11, weight="bold")

    # Add title
    plt.title("技术领域分布", fontsize=16)

    # Create legend
    plt.legend(
        wedges,
        labels,
        title="技术领域",
        loc="center left",
        bbox_to_anchor=(1, 0, 0.5, 1),
    )

    plt.tight_layout()

    # Save figure
    plt.savefig(
        os.path.join(output_dir, "domain_distribution.png"),
        dpi=300,
        bbox_inches="tight",
    )
    plt.close()


def generate_language_bar_chart(metadata, output_dir):
    """Generate a bar chart showing distribution of contributions by programming language."""
    print("Generating language usage bar chart...")

    languages = list(metadata["statistics"]["by_language"].keys())
    counts = list(metadata["statistics"]["by_language"].values())

    # Sort by count in descending order
    sorted_data = sorted(zip(languages, counts), key=lambda x: x[1], reverse=True)
    languages, counts = zip(*sorted_data) if sorted_data else ([], [])

    plt.figure(figsize=(10, 6))

    # Create horizontal bar chart
    bars = plt.barh(languages, counts, color=COLORS, alpha=0.8, height=0.6)

    # Add data labels
    for bar in bars:
        width = bar.get_width()
        plt.text(
            width + 0.5,
            bar.get_y() + bar.get_height() / 2,
            f"{int(width)}",
            ha="left",
            va="center",
            fontsize=10,
        )

    # Add title and labels
    plt.title("编程语言使用分布", fontsize=16)
    plt.xlabel("PR数量", fontsize=12)

    # Customize y-axis
    plt.gca().invert_yaxis()  # Highest count at the top

    # Add grid
    plt.grid(axis="x", linestyle="--", alpha=0.7)

    plt.tight_layout()

    # Save figure
    plt.savefig(
        os.path.join(output_dir, "language_distribution.png"),
        dpi=300,
        bbox_inches="tight",
    )
    plt.close()


def generate_project_scale_chart(metadata, output_dir):
    """Generate a chart showing distribution of contributions by project scale."""
    print("Generating project scale breakdown chart...")

    scales = ["mega", "large", "medium", "small"]
    scale_labels = [
        "超大项目 (>30k ⭐)",
        "大项目 (10k-30k ⭐)",
        "中等项目 (1k-10k ⭐)",
        "小项目 (<1k ⭐)",
    ]
    counts = [metadata["statistics"]["by_scale"][scale] for scale in scales]

    # Create figure with two subplots (pie chart and donut chart)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))

    # Pie chart
    wedges, texts, autotexts = ax1.pie(
        counts,
        labels=None,
        autopct="%1.1f%%",
        startangle=90,
        shadow=False,
        colors=COLORS[:4],
        wedgeprops={"edgecolor": "w", "linewidth": 1, "antialiased": True},
    )

    ax1.set_title("项目规模分布 (按PR数量)", fontsize=14)
    ax1.legend(
        wedges,
        scale_labels,
        title="项目规模",
        loc="center left",
        bbox_to_anchor=(0, 0, 0.5, 1),
    )

    # Donut chart showing impact (using star counts as weight)
    # We need to estimate the "impact" by multiplying PR count by average stars per category
    avg_stars = {
        "mega": 40000,  # >30k, estimate 40k average
        "large": 15000,  # 10k-30k, estimate 15k average
        "medium": 3000,  # 1k-10k, estimate 3k average
        "small": 300,  # <1k, estimate 300 average
    }

    impact = [counts[i] * avg_stars[scale] for i, scale in enumerate(scales)]

    wedges, texts, autotexts = ax2.pie(
        impact,
        labels=None,
        autopct="%1.1f%%",
        startangle=90,
        shadow=False,
        colors=COLORS[:4],
        wedgeprops={"edgecolor": "w", "linewidth": 1, "antialiased": True},
    )

    # Convert to donut chart
    center_circle = plt.Circle((0, 0), 0.5, fc="white")
    ax2.add_patch(center_circle)

    ax2.set_title("项目规模分布 (按影响力)", fontsize=14)
    ax2.legend(
        wedges,
        scale_labels,
        title="项目规模",
        loc="center left",
        bbox_to_anchor=(1, 0, 0.5, 1),
    )

    plt.tight_layout()

    # Save figure
    plt.savefig(
        os.path.join(output_dir, "project_scale_distribution.png"),
        dpi=300,
        bbox_inches="tight",
    )
    plt.close()


def generate_skill_radar_chart(metadata, output_dir):
    """Generate a radar chart showing skill distribution across different domains."""
    print("Generating skill radar chart...")

    # Define skills and proficiency levels
    # In a real implementation, this would be extracted from more detailed metadata
    skills = [
        "Python",
        "Shell",
        "C/C++",
        "Kotlin",
        "TypeScript",
        "Rust",
        "Linux系统",
        "容器技术",
        "并发编程",
    ]

    # Estimated proficiency levels (0-100)
    proficiency = [
        95,  # Python
        90,  # Shell
        75,  # C/C++
        80,  # Kotlin
        70,  # TypeScript
        60,  # Rust
        100,  # Linux系统
        85,  # 容器技术
        80,  # 并发编程
    ]

    # Create radar chart
    angles = np.linspace(0, 2 * np.pi, len(skills), endpoint=False)

    # Close the plot
    proficiency = np.concatenate((proficiency, [proficiency[0]]))
    angles = np.concatenate((angles, [angles[0]]))
    skills.append(skills[0])

    fig = plt.figure(figsize=(10, 10))
    ax = fig.add_subplot(111, polar=True)

    # Plot data
    ax.plot(angles, proficiency, "o-", linewidth=2, color=COLORS[0])
    ax.fill(angles, proficiency, alpha=0.25, color=COLORS[0])

    # Set category labels
    ax.set_thetagrids(angles * 180 / np.pi, skills, fontsize=12)

    # Set proficiency levels
    ax.set_yticks([20, 40, 60, 80, 100])
    ax.set_yticklabels(["20%", "40%", "60%", "80%", "100%"])
    ax.set_ylim(0, 100)

    # Add title
    plt.title("技能矩阵雷达图", fontsize=16, y=1.08)

    plt.tight_layout()

    # Save figure
    plt.savefig(
        os.path.join(output_dir, "skill_radar.png"), dpi=300, bbox_inches="tight"
    )
    plt.close()


def generate_all_visualizations(metadata, output_dir):
    """Generate all visualizations."""
    create_output_dir(output_dir)

    generate_contribution_heatmap(metadata, output_dir)
    generate_contribution_timeline(metadata, output_dir)
    generate_domain_pie_chart(metadata, output_dir)
    generate_language_bar_chart(metadata, output_dir)
    generate_project_scale_chart(metadata, output_dir)
    generate_skill_radar_chart(metadata, output_dir)

    print(f"All visualizations generated successfully in {output_dir}")


def main():
    """Main function to parse arguments and run visualization generation."""
    parser = argparse.ArgumentParser(
        description="Generate visualizations for open source contribution patterns"
    )
    parser.add_argument(
        "--output-dir",
        default="../visualizations",
        help="Directory to save visualization images",
    )

    args = parser.parse_args()

    # Get script directory
    script_dir = Path(__file__).resolve().parent

    # Construct paths
    metadata_path = script_dir.parent / "metadata.json"
    output_dir = Path(args.output_dir)
    if not output_dir.is_absolute():
        output_dir = script_dir / output_dir

    print(f"Loading metadata from: {metadata_path}")
    metadata = load_data(metadata_path)

    print(f"Generating visualizations in: {output_dir}")
    generate_all_visualizations(metadata, output_dir)


if __name__ == "__main__":
    main()
